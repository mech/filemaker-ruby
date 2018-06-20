require 'filemaker/model/field'
require 'filemaker/model/types/email'

module Filemaker
  module Model
    # `Fields` help to give `Model` their perceived schema. To find out your
    # fields, use `Model.fm_fields` or use Rails generator like:
    #
    #   rails generate filemaker:model filename database layout
    #
    # @example
    #   class Model
    #     include Filemaker::Model
    #
    #     string :id, identity: true
    #     string :title, fm_name: 'A_Title', default: 'Untitled'
    #     money  :salary
    #   end
    module Fields
      extend ActiveSupport::Concern

      TYPE_MAPPINGS = {
        string:     String,
        text:       String,
        date:       Date,
        datetime:   DateTime,
        money:      BigDecimal,
        number:     BigDecimal,
        integer:    Integer,
        email:      Filemaker::Model::Types::Email,
        object:     Filemaker::Model::Types::Attachment
      }.freeze

      included do
        class_attribute :fields, :identity
        self.fields = {}
      end

      # Apply default value when you instantiate a new model.
      # @See Model.new
      def apply_defaults
        attribute_names.each do |name|
          field = fields[name]
          instance_variable_set("@#{name}", field.default_value)
        end
      end

      def attribute_names
        self.class.attribute_names
      end

      def fm_names
        fields.values.map(&:fm_name)
      end

      def attributes
        fields.keys.each_with_object({}) do |field, hash|
          # Attributes must be strings, not symbols - See
          # http://api.rubyonrails.org/classes/ActiveModel/Serialization.html
          hash[field.to_s] = instance_variable_get("@#{field}")

          # If we use public_send(field) will encounter Stack Too Deep
        end
      end

      module ClassMethods
        def attribute_names
          fields.keys
        end

        Filemaker::Model::Type.registry.each_key do |type|
          define_method(type) do |*args|
            options = args.last.is_a?(Hash) ? args.pop : {}
            field_names = args

            field_names.each do |name|
              add_field(name, Filemaker::Model::Type.registry[type], options)
              create_accessors(name)
            end
          end
        end

        # TYPE_MAPPINGS.each_key do |type|
        #   define_method(type) do |*args|
        #     # TODO: It will be good if we can accept lambda also
        #     options = args.last.is_a?(Hash) ? args.pop : {}
        #     field_names = args

        #     field_names.each do |name|
        #       add_field(name, TYPE_MAPPINGS[type.to_sym], options)
        #       create_accessors(name)
        #     end
        #   end
        # end

        def add_field(name, type, options)
          name = name.to_s.freeze
          fields[name] = Filemaker::Model::Field.new(name, type, options)
          self.identity = fields[name] if options[:identity]
        end

        def create_accessors(name)
          # Normalize it so ActiveModel::Serialization can work
          name = name.to_s

          define_attribute_methods name

          # Reader
          define_method(name) do
            instance_variable_get("@#{name}")
          end

          # Writer - We try to map to the correct type, if not we just return
          # original.
          define_method("#{name}=") do |value|
            # new_value = fields[name].coerce_for_assignment(value, self.class)

            new_value = fields[name].serialize_for_update(value)

            public_send("#{name}_will_change!") \
              if new_value != public_send(name)

            instance_variable_set("@#{name}", new_value)
          end

          # Predicate
          define_method("#{name}?") do
            # See ActiveRecord::AttributeMethods::Query implementation
            public_send(name) == true || public_send(name).present?
          end
        end

        # Find FileMaker's real name given either the attribute name or the real
        # FileMaker name.
        def find_field_by_name(name)
          name = name.to_s
          fields.values.find do |f|
            f.name == name || f.fm_name == name
          end
        end
      end
    end
  end
end
