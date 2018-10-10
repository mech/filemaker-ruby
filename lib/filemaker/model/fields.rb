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

              next unless options[:max_repeat] && options[:max_repeat] > 1

              # We have repeating fields
              # It will create [max_repeat] number of attribute with names like:
              # xxx__1, xxx__2, xxx__3
              # Their fm_name will be xxx(1), xxx(2), xxx(3)
              options[:max_repeat].times do |idx|
                index = idx + 1
                repeated_field_name = "#{name}__#{index}"
                fm_name = (options.fetch(:fm_name) { name }).to_s.downcase.freeze
                add_field(
                  repeated_field_name,
                  Filemaker::Model::Type.registry[type],
                  options.merge(fm_name: "#{fm_name}(#{index})")
                )
                create_accessors(repeated_field_name)
              end
            end
          end
        end

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
        # FIXME - This may have ordering problem. If fm_name is the same as the
        # field name.
        def find_field_by_name(name)
          name = name.to_s
          fields.values.find do |f|
            f.name == name || f.fm_name == name

            # Unfortunately can't use this as builder.rb need to find field based
            # on fm_name
            # Always find by attribute name for now
            # f.name == name
          end
        end
      end
    end
  end
end
