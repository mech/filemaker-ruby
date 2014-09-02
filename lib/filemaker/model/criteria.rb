require 'filemaker/model/selectable'
require 'filemaker/model/optional'

module Filemaker
  module Model
    class Criteria
      include Enumerable
      include Selectable
      include Optional

      attr_reader :klass, :selector, :options

      def initialize(klass)
        @klass    = klass
        @selector = {}
        @options  = {}
      end

      def to_s
        "#{selector}, #{options}"
      end
    end
  end
end
