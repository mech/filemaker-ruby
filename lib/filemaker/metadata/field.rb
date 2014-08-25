require 'date'
require 'bigdecimal'

module Filemaker
  module Metadata
    class Field
      # @return [String] name of the field
      attr_reader :name

      # @return [String] one of 'text', 'number', 'date', 'time',
      # 'timestamp', or 'container'
      attr_reader :data_type

      # @return [String] one of 'normal', 'calculation', or 'summary'
      attr_reader :field_type

      # @return [Integer] how many times the <data> repeats
      attr_reader :repeats

      # @return [Boolean] indicates if field is required or not
      attr_reader :required

      # @return [Boolean] whether it is a global field
      attr_reader :global

      def initialize(definition, resultset)
        @name       = definition['name']
        @data_type  = definition['result']
        @field_type = definition['type']
        @repeats    = definition['max-repeat'].to_i
        @global     = convert_to_boolean(definition['global'])
        @required   = convert_to_boolean(definition['not-empty'])
        @resultset  = resultset
      end

      def coerce(value)
        value = value.to_s.strip
        return nil if value.empty?

        case data_type
        when 'number'
          BigDecimal.new(value)
        when 'date'
          Date.strptime(value, @resultset.date_format)
          # Date.strptime(Date.parse(value).strftime(@resultset.date_format), @resultset.date_format)
        when 'time'
          DateTime.strptime("1/1/-4712 #{value}", @resultset.timestamp_format)
        when 'timestamp'
          DateTime.strptime(value, @resultset.timestamp_format)
        when 'container'
          URI.parse("#{@resultset.server.host}#{value}")
        else
          value
        end
      rescue Exception => e
        msg = "Could not coerce #{value} due to #{e.message}"
        raise Filemaker::Error::CoerceError, msg
      end

      private

      # 'yes' != 'no' => true
      # 'no'  != 'no' => false
      def convert_to_boolean(value)
        value != 'no'
      end
    end
  end
end
