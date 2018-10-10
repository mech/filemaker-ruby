module Filemaker
  module Model
    module Types
      class Time
        def self.__filemaker_cast_to_ruby_object(value)
          return nil if value.nil?
          return value if value.is_a?(::Time)

          ::Time.parse(value.to_s)
        end

        def self.__filemaker_serialize_for_update(value)
          return nil if value.nil?
          return value if value.is_a?(::Time)

          ::Time.parse(value.to_s)
        end

        def self.__filemaker_serialize_for_query(value)
          return nil if value.nil?
          return value if value.is_a?(::Time) || value.is_a?(String)

          ::Time.parse(value.to_s)
        end
      end
    end
  end
end
