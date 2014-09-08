module Filemaker
  module Model
    class Field
      attr_reader :name, :type, :default_value, :fm_name

      def initialize(name, type, options = {})
        @name = name
        @type = type
        @default_value = coerce(options.fetch(:default) { nil })

        # We need to downcase because Filemaker::Record is
        # HashWithIndifferentAndCaseInsensitiveAccess
        @fm_name = (options.fetch(:fm_name) { name }).to_s.downcase
      end

      # From FileMaker to Ruby
      def coerce(value)
        return nil if value.nil?

        if @type == String
          value.to_s
        elsif @type == Integer
          value.to_i
        elsif @type == BigDecimal
          BigDecimal.new(value.to_s)
        elsif @type == Date
          return value if value.is_a? Date
          Date.parse(value.to_s)
        elsif @type == DateTime
          return value if value.is_a? DateTime
          DateTime.parse(value.to_s)
        else
          value
        end
      end
    end
  end
end
