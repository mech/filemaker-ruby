module Filemaker
  module Model
    module Selectable
      # Find records based on query hash.
      #
      # @param [Hash] criterion Hash criterion
      #
      # @return [Filemaker::Model::Criteria]
      def where(criterion)
        fail Filemaker::Error::MixedClauseError,
             "Can't mix 'where' with 'in'." if chains.include?(:in)
        chains.push(:where)

        @selector ||= {}
        selector.merge!(with_model_fields(criterion))
        yield options if block_given?
        self
      end

      # Find records based on model ID. If passed a hash, will use `where`.
      #
      # @example Find by model ID.
      #   Model.find('CAID324')
      #
      # @example Find with a Hash. This will delegate to `where`.
      #   Model.find(name: 'Bob', salary: 4000)
      #
      # @param [Integer, String, Hash] criterion
      #
      # @return [Filemaker::Model::Criteria, Filemaker::Model]
      def find(criterion)
        return where(criterion) if criterion.is_a? Hash

        # Find using model ID (may not be the -recid)
        id = criterion.gsub(/\A=*/, '=') # Always append '=' for ID

        # If we are finding with ID, we just limit to one and return
        # immediately.
        limit(1).first
      end

      %w(eq cn bw ew gt gte lt lte neq).each do |operator|
        define_method operator do |criterion|
          fail Filemaker::Error::MixedClauseError,
               "Can't mix 'where' with 'in'." if chains.include?(:in)
          chains.push(operator.to_sym)
          @selector ||= {}
          criterion = with_model_fields(criterion)
          criterion.each_pair do |key, value|
            selector["#{key}.op"] = operator
          end

          selector.merge!(criterion)
          self
        end
      end

      alias_method :equals, :eq
      alias_method :contains, :cn
      alias_method :begins_with, :bw
      alias_method :ends_with, :ew
      alias_method :not, :neq

      # Find records based on FileMaker's compound find syntax.
      def in(criterion)
        fail Filemaker::Error::MixedClauseError,
             "Can't mix 'in' with 'where'." if chains.include?(:where)
        chains.push(:in)
        @selector ||= []

        become_array(criterion).each do |hash|
          accepted_hash = with_model_fields(hash)
          @selector << accepted_hash
        end

        yield options if block_given?
        self
      end

      # Used with `where` to specify how the queries are combined. Default is
      # 'and', so you won't find any `and` method.
      #
      # @example Mix with where to 'or' query
      #   Model.where(name: 'Bob').or(age: '50')
      #
      # @param [Hash] criterion Hash criterion
      #
      # @return [Filemaker::Model::Criteria]
      def or(criterion)
        fail Filemaker::Error::MixedClauseError,
             "Can't mix 'or' with 'in'." if chains.include?(:in)
        @selector ||= {}
        selector.merge!(with_model_fields(criterion))
        options[:lop] = 'or'
        yield options if block_given?
        self
      end

      private

      # Filter out any fields that do not match model's fields.
      def with_model_fields(criterion)
        accepted_fields = {}

        criterion.each_pair do |key, value|
          field = model.field_by_name(key)

          # We do not serialize at this point, as we are still in Ruby-land.
          # Filemaker::Server will help us serialize into FileMaker format.
          accepted_fields[field.fm_name] = field.coerce(value) if field
        end

        accepted_fields
      end

      def become_array(value)
        value.is_a?(Array) ? value : [value]
      end
    end
  end
end
