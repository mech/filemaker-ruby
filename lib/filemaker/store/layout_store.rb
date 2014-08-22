module Filemaker
  module Store
    class LayoutStore < Hash
      def initialize(server, database)
        @server = server
        @database = database
      end

      def [](name)
        super || self[name] = Filemaker::Layout.new(name, @server, @database)
      end

      def all
        args = { '-db' => @database.name }
        response, _params = @server.perform_request(:post, '-layoutnames', args)
        resultset = Filemaker::Resultset.new(@server, response.body)
        resultset.map do |record|
          record['LAYOUT_NAME']
        end
      end
    end
  end
end
