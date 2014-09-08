require 'filemaker/model/field'

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
        class_attribute :fields, :identity
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
          fields[name] = Filemaker::Model::Field.new(name, type, options)
          self.identity = fields[name] if options[:identity]
        end

        def create_accessors(name)
          define_method(name) { attributes[name] }
          define_method("#{name}=") do |value|
            attributes[name] = fields[name].coerce(value)
          end
          define_method("#{name}?") do
            attributes[name] == true || attributes[name].present?
          end
        end

        # Find FileMaker's real name given either the attribute name or the real
        # FileMaker name.
        def find_field_by_name(name)
          fields.values.find do |f|
            f.name == name.to_sym || f.fm_name == name.to_s
          end
        end
      end
    end
  end
end
