require 'filemaker/model/types/email'

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

      # From FileMaker to Ruby.
      #
      # If the value is `==` (match empty) or `=*` (match record), then we will
      # skip coercion.
      #
      # Date and DateTime will be special. If the value is a String, the query
      # may be '2016', '3/2016' or '3/24/2016' for example.
      def coerce(value)
        return nil if value.nil?
        return value if value == '==' || value == '=*'
        return value if value =~ /(\.\.\.)/

        if @type == String
          value.to_s
        elsif @type == Integer
          value.to_i
        elsif @type == BigDecimal
          BigDecimal.new(value.to_s)
        elsif @type == Date
          return value if value.is_a? Date
          return value.to_s if value.is_a? String
          Date.parse(value.to_s)
        elsif @type == DateTime
          return value if value.is_a? DateTime
          return value.to_s if value.is_a? String
          DateTime.parse(value.to_s)
        elsif @type == Filemaker::Model::Types::Email
          return value if value.is_a? Filemaker::Model::Types::Email
          Filemaker::Model::Types::Email.new(value)
        else
          value
        end
      rescue StandardError => e
        warn "[#{e.message}] Could not coerce #{name}: #{value}"
        value
      end
    end
  end
end
