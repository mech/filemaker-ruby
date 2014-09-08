require 'filemaker/model/selectable'
require 'filemaker/model/optional'
require 'filemaker/model/builder'

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

      # @return [Filemaker::Model] the class of the model
      attr_reader :klass

      # @return [Hash. Array] represents the query arguments
      attr_reader :selector

      # @return [Hash] options like skip, limit and order
      attr_reader :options

      # @return [Array] keep track of where clause and in clause to not mix them
      attr_reader :chains

      def initialize(klass)
        @klass    = klass
        @options  = {}
        @chains   = []
      end

      def to_s
        "#{selector}, #{options}"
      end

      def each
        execute.each { |record| yield record } if block_given?
      end

      def first
        limit(1).execute.first
      end

      def all
        execute
      end

      def limit?
        !options[:max].nil?
      end

      # The count this criteria is capable of returning
      #
      # @return [Integer] the count
      def count
        limit(0)
        if chains.include?(:where)
          klass.api.find(selector, options).count
        elsif chains.include?(:in)
          klass.api.query(selector, options).count
        else
          klass.api.findall(options).count
        end
      end

      protected

      def execute
        resultset = []

        if chains.include?(:where)
          # Use -find
          resultset = klass.api.find(selector, options)
        elsif chains.include?(:in)
          # Use -findquery
          resultset = klass.api.query(selector, options)
        else
          # Use -findall
          limit(1) unless limit?
          resultset = klass.api.findall(options)
        end

        Filemaker::Model::Builder.collection(resultset, klass)
      end
    end
  end
end
