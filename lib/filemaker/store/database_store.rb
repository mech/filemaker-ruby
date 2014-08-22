module Filemaker
  module Store
    class DatabaseStore < Hash
      def initialize(server)
        @server = server
      end

      def [](name)
        super || self[name] = Filemaker::Database.new(name, @server)
      end

      def all
        response, _params = @server.perform_request(:post, '-dbnames', nil)
        resultset = Filemaker::Resultset.new(@server, response.body)
        resultset.map do |record|
          record['DATABASE_NAME']
        end
      end
    end
  end
end
