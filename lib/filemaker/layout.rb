module Filemaker
  class Layout
    # @return [String] layout name
    attr_reader :name

    # @return [Filemaker::Server] the server
    attr_reader :server

    # @return [String] the database
    attr_reader :database

    def initialize(name, server, database)
      @name = name
      @server = server
      @database = database
    end

    def default_params
      { '-db' => database.name, '-lay' => name }
    end
  end
end
