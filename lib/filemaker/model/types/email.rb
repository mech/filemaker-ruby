module Filemaker
  module Model
    module Types
      class Email
        def initialize(value)
          @value = value
        end

        def value
          email = @value&.strip&.split(%r{,|\(|\/|\s})
                  &.reject(&:empty?)&.first&.downcase
                  &.gsub(/[\uFF20\uFE6B\u0040]/, '@')

          email&.include?('@') ? email : nil
        end

        def value=(v)
          self.value = v
        end

        def to_s
          value
        end

        # In FileMaker, at-sign is for wildcard query. In order to search for
        # email, we need to escape at-sign. Note the single-quote escaping!
        def to_query
          value.gsub('@', '\@')
        end
      end
    end
  end
end
