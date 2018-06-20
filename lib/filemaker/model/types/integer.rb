module Filemaker
  module Model
    module Types
      class Integer
        def self.__filemaker_cast_to_ruby_object(value)
          return value if value.is_a?(::Integer)
          value.to_i
        end

        def self.__filemaker_serialize_for_update(value)
          return value if value.is_a?(::Integer)
          value.to_i
        end

        def self.__filemaker_serialize_for_query(value)
          return value if value.is_a?(::Integer)
          value.to_i
        end
      end
    end
  end
end
