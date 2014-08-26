module Filemaker
  module Store
    class ScriptStore < Hash
      def initialize(server, database)
        @server = server
        @database = database
      end

      def [](name)
        super || self[name] = Filemaker::Script.new(name, @server, @database)
      end

      def all
        args = { '-db' => @database.name }
        response, _params = @server.perform_request(:post, '-scriptnames', args)
        resultset = Filemaker::Resultset.new(@server, response.body)
        resultset.map do |record|
          record['SCRIPT_NAME']
        end
      end
    end
  end
end
