module Filemaker
  module Model
    module Types
      class FloatWithInteger
        def self.__filemaker_cast_to_ruby_object(value)
          return nil if value.nil?
          return value if value.is_a?(::BigDecimal)

          BigDecimal(value.to_s.squish)
        end

        def self.__filemaker_serialize_for_update(value)
          return nil if value.nil?
          # return value if value.is_a?(::BigDecimal)

          # Directly convert to BigDecimal using to_s first
          value = BigDecimal(value.to_s.squish)

          if value.zero?
            0
          elsif value.frac.zero?
            value.to_i
          else
            value
          end
        end

        def self.__filemaker_serialize_for_query(value)
          return nil if value.nil?
          return value if value.is_a?(::BigDecimal)

          BigDecimal(value.to_s.squish)
        end
      end
    end
  end
end
