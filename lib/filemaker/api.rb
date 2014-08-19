Dir[File.expand_path('../api/query_commands/**/*.rb', __FILE__)].each do |lib|
  require lib
end

module Filemaker
  module Api
    module QueryCommands; end

    def self.included(base)
      base.send :include, Filemaker::Api::QueryCommands
    end
  end
end
