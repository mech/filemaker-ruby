require 'filemaker/model/field'

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
        string:   String,
        date:     Date,
        datetime: DateTime,
        money:    BigDecimal,
        number:   BigDecimal,
        integer:  Integer
      }

      included do
        class_attribute :fields, :identity
        self.fields = {}
      end

      # Apply default value when you instantiate a new model.
      # @See Model.new
      def apply_defaults
        attribute_names.each do |name|
          field = fields[name]
          attributes[name] = field.default_value
        end
      end

      def attribute_names
        self.class.attribute_names
      end

      def fm_names
        fields.values.map(&:fm_name)
      end

      module ClassMethods
        def attribute_names
          fields.keys
        end

        %w(string date datetime money integer number).each do |type|
          define_method(type) do |*args|
            # TODO: It will be good if we can accept lambda also
            options = args.last.is_a?(Hash) ? args.pop : {}
            field_names = args

            field_names.each do |name|
              add_field(name, TYPE_MAPPINGS[type.to_sym], options)
              create_accessors(name)
            end
          end
        end

        def add_field(name, type, options)
          name = name.to_s
          fields[name] = Filemaker::Model::Field.new(name, type, options)
          self.identity = fields[name] if options[:identity]
        end

        def create_accessors(name)
          name = name.to_s # Normalize it so ActiveModel::Serialization can work

          define_attribute_methods name

          # Reader
          define_method(name) { attributes[name] }

          # Writer - We try to map to the correct type, if not we just return
          # original.
          define_method("#{name}=") do |value|
            public_send("#{name}_will_change!") unless value == attributes[name]
            attributes[name] = fields[name].coerce(value)
          end

          # Predicate
          define_method("#{name}?") do
            attributes[name] == true || attributes[name].present?
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
