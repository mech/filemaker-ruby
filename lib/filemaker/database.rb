module Filemaker
  class Database
    # @return [String] database name
    attr_reader :name

    # @return [Filemaker::Server] the server
    attr_reader :server

    # @return [Filemaker::Store::LayoutStore] the layout store
    attr_reader :layouts
    alias layout layouts
    alias lay layouts

    # @return [Filemaker::Store::ScriptStore] the script store
    attr_reader :scripts

    def initialize(name, server)
      @name = name
      @server = server
      @layouts = Store::LayoutStore.new(server, self)
      @scripts = Store::ScriptStore.new(server, self)
    end

    # A very convenient way to access some layout from this database
    def [](layout_name)
      layouts[layout_name]
    end
  end
end
