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
        selector.merge!(klass.with_model_fields(criterion))
        yield options if block_given?
        self
      end

      # Find records based on model ID. If passed a hash, will use `where`.
      # On the last resort, if we seriously can't find using `where`, we find
      # it thru the `recid`. Is this a good design? We will see in production.
      # Performance note: 2 HTTP requests if going that last resort route.
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
        id = criterion.to_s.gsub(/\A=*/, '=') # Always append '=' for ID

        # If we are finding with ID, we just limit to one and return
        # immediately. Last resort is to use the recid to find.
        where(klass.identity.name => id).first || recid(criterion)
      end

      # Using FileMaker's internal ID to find the record.
      def recid(id)
        return nil if id.blank?

        @selector = {} # We want to clear the selector when it comes to recid
        selector['-recid'] = id
        chains.push(:where) unless chains.include?(:where) # No double :where
        first
      end

      %w(eq cn bw ew gt gte lt lte neq).each do |operator|
        define_method(operator) do |criterion, &block|
          fail Filemaker::Error::MixedClauseError,
               "Can't mix 'where' with 'in'." if chains.include?(:in)
          chains.push(operator.to_sym)
          chains.push(:where) unless chains.include?(:where) # Just one time
          @selector ||= {}

          if operator == 'bw'
            criterion = klass.with_model_fields(criterion, false)
          else
            criterion = klass.with_model_fields(criterion)
          end

          criterion.each_key do |key|
            selector["#{key}.op"] = operator
          end

          selector.merge!(criterion)

          # Inside define_method, we cannot have yield or block_given?, so we
          # just use &block
          block.call(options) if block
          self
        end
      end

      alias_method :equals, :eq
      alias_method :contains, :cn
      alias_method :begins_with, :bw
      alias_method :ends_with, :ew
      alias_method :not, :neq

      # Find records based on FileMaker's compound find syntax.
      #
      # @example Find using a single hash
      #   Model.in(nationality: %w(Singapore Malaysia))
      #
      # @example Find using an array of hashes
      #   Model.in([{nationality: %w(Singapore Malaysia)}, {age: [20, 30]}])
      #
      # @param [Hash, Array]
      #
      # @return [Filemaker::Model::Criteria]
      def in(criterion, negating = false)
        fail Filemaker::Error::MixedClauseError,
             "Can't mix 'in' with 'where'." if chains.include?(:where)
        chains.push(:in)
        @selector ||= []

        become_array(criterion).each do |hash|
          accepted_hash = klass.with_model_fields(hash)
          accepted_hash.merge!('-omit' => true) if negating
          @selector << accepted_hash
        end

        yield options if block_given?
        self
      end

      # Simply append '-omit' => true to all criteria
      def not_in(criterion)
        self.in(criterion, true)
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
        selector.merge!(klass.with_model_fields(criterion))
        options[:lop] = 'or'
        yield options if block_given?
        self
      end

      private

      def become_array(value)
        value.is_a?(Array) ? value : [value]
      end
    end
  end
end
