module Filemaker
  module Model
    module Types
      class BigDecimal
        def self.__filemaker_cast_to_ruby_object(value)
          return value if value.is_a?(::BigDecimal)
          BigDecimal(value.to_s)
        end

        def self.__filemaker_serialize_for_update(value)
          return value if value.is_a?(::BigDecimal)
          BigDecimal(value.to_s)
        end

        def self.__filemaker_serialize_for_query(value)
          return value if value.is_a?(::BigDecimal)
          BigDecimal(value.to_s)
        end
      end
    end
  end
end
