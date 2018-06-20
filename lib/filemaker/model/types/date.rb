module Filemaker
  module Model
    module Types
      class Date
        def self.__filemaker_cast_to_ruby_object(value)
          return value if value.is_a?(::Date)
          ::Date.parse(value.to_s)
        end

        def self.__filemaker_serialize_for_update(value)
          return value if value.is_a?(::Date)
          ::Date.parse(value.to_s)
        end

        def self.__filemaker_serialize_for_query(value)
          # If we are doing date range query like
          # Model.where(date: '12/2018')
          return value if value.is_a?(::Date) || value.is_a?(String)
          ::Date.parse(value.to_s)
        end
      end
    end
  end
end
