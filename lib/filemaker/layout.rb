module Filemaker
  class Layout
    include Api

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

    # @return [Filemaker::Resultset]
    def perform_request(action, args, options)
      response, params = server
        .perform_request(:post, action, default_params.merge(args), options)

      Filemaker::Resultset.new(server, response.body, params)
    end
  end
end
