require 'filemaker/model/selectable'
require 'filemaker/model/optional'

module Filemaker
  module Model
    # Criteria encapsulates query arguments and options to represent a single
    # query. It has convenient query DSL like +where+ and +in+ to represent both
    # -find and -findquery FileMaker query. On top of that you can negate any
    # query with the +not+ clause to omit selection.
    class Criteria
      include Enumerable
      include Selectable
      include Optional

      # @return [Filemaker::Model] the model this criteria will act on
      attr_reader :model

      # @return [Hash. Array] represents the query arguments
      attr_reader :selector

      # @return [Hash] options like skip, limit and order
      attr_reader :options

      # @return [Array] keep track of where clause and in clause to not mix them
      attr_reader :chains

      def initialize(model)
        @model    = model
        @options  = {}
        @chains   = []
      end

      def to_s
        "#{selector}, #{options}"
      end
    end
  end
end
