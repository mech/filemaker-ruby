module Filemaker
  module Model
    module Selectable
      # Find records based on query hash.
      #
      # @param [Hash] query The query hash.
      #
      # @return [Filemaker::Model::Criteria]
      def where(query, options = {})
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
      # @param [Integer, String, Hash] id_or_query
      #
      # @return [Filemaker::Model::Criteria, Filemaker::Model]
      def find(id_or_query)
        return where(id_or_query) if id_or_query.is_a? Hash

        # Find using model ID (may not be the -recid)
        id = id_or_query.gsub(/\A=*/, '=') # Always append '=' for ID

        # If we are finding with ID, we just limit to one and return
        # immediately.
        self.limit(1).first
      end

      def not(query)
      end

      def in(query)
      end
    end
  end
end
