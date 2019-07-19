module Filemaker
  module Model
    class Field
      attr_reader :name, :type, :default_value, :fm_name, :max_repeat

      def initialize(name, type, options = {})
        @name = name
        @type = type
        @max_repeat = options.fetch(:max_repeat) { 1 }
        @default_value = serialize_for_update(options.fetch(:default) { nil })

        # We need to downcase because Filemaker::Record is
        # HashWithIndifferentAndCaseInsensitiveAccess
        @fm_name = (options.fetch(:fm_name) { name }).to_s.downcase.freeze
      end

      # Will delegate to the underlying @type for casting
      # From raw input to Ruby type
      def cast(value)
        return value if value.nil?
        return value if value.is_a?(Array) && @max_repeat > 1

        @type.__filemaker_cast_to_ruby_object(value)
      rescue StandardError => e
        warn "[#{e.message}] Could not cast: #{name}=#{value}"
        value
      end

      # Convert to Ruby type situable for making FileMaker update
      # For attr_writer
      def serialize_for_update(value)
        return value if value.nil?

        if value.is_a?(Array) && @max_repeat > 1
          value.map { |v| @type.__filemaker_serialize_for_update(v) }

          # @max_repeat.times do |idx|
          #   index = idx + 1
          #   repeated_field_name = "@#{@name}__#{index}"
          #   repeated_field_value = @type.__filemaker_serialize_for_update(value[idx])
          #   instance_eval do
          #     instance_variable_set(repeated_field_name, repeated_field_value)
          #   end
          # end
        else
          @type.__filemaker_serialize_for_update(value)
        end
      rescue StandardError => e
        warn "[#{e.message}] Could not serialize for update: #{name}=#{value}"
        value
      end

      # Convert to Ruby type situable for making FileMaker query
      def serialize_for_query(value)
        return value if value.nil?
        return value if value =~ /^==|=\*/
        return value if value =~ /(\.\.\.)/
        return value if value =~ /\A(<|<=|>|>=)/

        @type.__filemaker_serialize_for_query(value)
      rescue StandardError => e
        warn "[#{e.message}] Could not serialize for query: #{name}=#{value}"
        value
      end
    end
  end
end
