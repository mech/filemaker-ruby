module Filemaker
  module Model
    module Types
      class Email
        def self.__filemaker_cast_to_ruby_object(value)
          email = value&.strip&.split(%r{,|\(|\/|\s})
                  &.reject(&:empty?)&.first&.downcase
                  &.gsub(/[\uFF20\uFE6B\u0040]/, '@')

          email&.include?('@') ? email : nil
        end

        def self.__filemaker_serialize_for_update(value)
          __filemaker_cast_to_ruby_object(value)
        end

        def self.__filemaker_serialize_for_query(value)
          value.gsub('@', '\@')
        end
      end
    end
  end
end
