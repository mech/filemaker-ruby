module Filemaker
  module Store
    class DatabaseStore < Hash
      include Filemaker::Api

      def initialize(server)
        @server = server
      end

      def [](name)
        super || self[name] = Filemaker::Database.new(name, @server)
      end

      alias_method :all, :dbnames
    end
  end
end
