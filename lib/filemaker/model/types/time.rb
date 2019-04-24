module Filemaker
  module Model
    module Types
      class Time
        def self.__filemaker_cast_to_ruby_object(value)
          return nil if value.nil?
          return value.strftime("%H:%M") if value.is_a?(::Time)

          ::Time.parse(value.to_s)
        end

        def self.__filemaker_serialize_for_update(value)
          return nil if value.nil?
          return value.strftime("%H:%M") if value.is_a?(::Time) || value.is_a?(::DateTime)

          # Could be a string like "09:00" already
          value
        end

        def self.__filemaker_serialize_for_query(value)
          return nil if value.nil?
          return value.strftime("%H:%M") if value.is_a?(::Time)

          value
        end
      end
    end
  end
end
