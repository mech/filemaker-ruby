module Filemaker
  module Model
    module Fields
      extend ActiveSupport::Concern

      attr_reader :attributes

      TYPE_MAPPINGS = {
        string: String,
        date: Date,
        datetime: DateTime,
        money: BigDecimal,
        integer: Integer,
        number: BigDecimal
      }

      included do
        class_attribute :fields
        self.fields = {}
      end

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

      def to_a
        [self]
      end

      module ClassMethods
        def attribute_names
          fields.keys
        end

        %w(string date datetime money integer number).each do |type|
          define_method(type) do |*args|
            options = args.last.is_a?(Hash) ? args.pop : {}
            field_names = args

            field_names.each do |name|
              add_field(name, TYPE_MAPPINGS[type.to_sym], options)
              create_accessors(name)
            end
          end
        end

        def add_field(name, type, options)
          fields[name] = Filemaker::Model::Field.new(name, type, options)
        end

        def create_accessors(name)
          define_method(name) { attributes[name] }
          define_method("#{name}=") do |value|
            # Make use of fields[name] to do coercion
            attributes[name] = fields[name].coerce(value)
          end
        end
      end
    end
  end
end
