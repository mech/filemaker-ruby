module Filemaker
  module Api
    module QueryCommands
      # Find records using compound find query command.
      #
      # query(status: 'open', title: 'web') => (q0,q1)
      # query(status: %w(open closed))      => (q0);(q1)
      #
      def query(array_hash)
        compound_find = CompoundFind.new(array_hash)

        query_hash = compound_find.key_values.merge(
          '-query' => compound_find.key_maps_string
        )

        findquery(query_hash)
      end

      # Raw -findquery if you want to construct your own.
      def findquery(query_hash, options = {})
        perform_request('-findquery', query_hash, options)
      end

      # Convenient compound find query builder
      class CompoundFind
        attr_reader :key_values, :key_maps_string

        def initialize(query)
          @query = query
          @key_values = {}
          @key_maps = []
          @key_maps_string = ''
          @counter = 0

          become_array(@query).each do |hash|
            build_key_map(build_key_values(hash))
          end

          translate_key_maps
        end

        private

        def build_key_values(hash)
          q_tag_array = []
          omit = hash.delete('-omit')

          hash.each do |key, value|
            q_tag = []
            become_array(value).each do |v|
              @key_values["-q#{@counter}"] = key
              @key_values["-q#{@counter}.value"] = v
              q_tag << "q#{@counter}"
              @counter += 1
            end
            q_tag_array << q_tag
          end

          (q_tag_array << '-omit') if omit
          q_tag_array
        end

        def build_key_map(q_tag_array)
          omit = q_tag_array.delete('-omit')
          len = q_tag_array.length
          result = q_tag_array.flatten.combination(len).select do |c|
            q_tag_array.all? { |a| (a & c).size > 0 }
          end.each { |c| c.unshift('-omit') if omit }
          @key_maps.concat result
        end

        def translate_key_maps
          @key_maps_string << @key_maps.map do |a|
            "#{'!' if a.delete('-omit')}(#{a.join(',')})"
          end.join(';')
        end

        def become_array(value)
          value.is_a?(Array) ? value : [value]
        end
      end
    end
  end
end
