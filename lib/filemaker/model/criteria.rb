require 'filemaker/model/selectable'
require 'filemaker/model/optional'
require 'filemaker/model/builder'
require 'filemaker/model/pagination'

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
      include Pagination

      # @return [Filemaker::Model] the class of the model
      attr_reader :klass, :loaded

      # @return [Hash. Array] represents the query arguments
      attr_reader :selector

      # @return [Hash] options like skip, limit and order
      attr_reader :options

      # @return [Array] keep track of where clause and in clause to not mix them
      attr_reader :chains

      alias loaded? loaded

      def initialize(klass)
        @klass    = klass
        @options  = {}
        @chains   = []
        @_page    = 1
        @loaded   = false
      end

      def to_s
        "#{selector}, #{options}"
      end

      def to_a
        records.dup
      end

      def records
        load
        @records
      end

      # Causes the records to be loaded from FM if they have not been loaded
      # already
      def load
        return if loaded?

        @records = all
        @loaded = true
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
        if chains.include?(:where)
          klass.api.find(selector, options.merge(max: 0)).count
        elsif chains.include?(:in)
          klass.api.query(selector, options.merge(max: 0)).count
        elsif chains.include?(:custom)
          klass.api.findquery(selector, options.merge(max: 0)).count
        else
          klass.api.findall(options.merge(max: 0)).count
        end
      end

      protected

      def execute
        lines = caller

        ActiveSupport::Notifications.instrument(
          :filemaker,
          model_name: klass.to_s,
          selector: selector,
          options: options,
          lines: lines
        ) do
          resultset = []
          paginated = chains.include?(:page)

          if chains.include?(:where)
            # Use -find
            resultset = klass.api.find(selector, options)
          elsif chains.include?(:in)
            # Use -findquery
            resultset = klass.api.query(selector, options)
          elsif chains.include?(:custom)
            # Use -findquery directly
            resultset = klass.api.findquery(selector, options)
          else
            # Use -findall
            limit(1) unless limit?
            resultset = klass.api.findall(options)
          end

          models = Filemaker::Model::Builder.collection(resultset, klass)

          if defined?(Kaminari) && paginated
            Kaminari.paginate_array(models, total_count: resultset.count)
                    .page(@_page)
                    .per(options[:max])
          else
            models
          end
        end
      end
    end
  end
end
