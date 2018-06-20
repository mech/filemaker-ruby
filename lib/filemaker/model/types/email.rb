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

        # def initialize(value)
        #   # to_s incoming value, this can prevent similar type from
        #   # nesting deeply
        #   @value = value.nil? ? nil : value.to_s
        # end

        # def value
        #   email = @value&.strip&.split(%r{,|\(|\/|\s})
        #           &.reject(&:empty?)&.first&.downcase
        #           &.gsub(/[\uFF20\uFE6B\u0040]/, '@')

        #   email&.include?('@') ? email : nil
        # end

        # def value=(v)
        #   self.value = v
        # end

        # def to_s
        #   value
        # end

        # def ==(other)
        #   to_s == other.to_s
        # end
        # alias eql? ==

        # # In FileMaker, at-sign is for wildcard query. In order to search for
        # # email, we need to escape at-sign. Note the single-quote escaping!
        # # e.g. 'a@host.com' will become 'a\\@host.com'
        # def to_query
        #   value.gsub('@', '\@')
        # end


      end
    end
  end
end
