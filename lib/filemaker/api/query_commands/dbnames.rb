module Filemaker
  module Api
    module QueryCommands
      # Using -dbnames command to get all the available databases from Filemaker
      # server. Based on permission, the list may not be complete.
      def dbnames
        response = @server.perform_request(:get, { '-dbnames' => '' })
        resultset = Filemaker::Resultset.new(@server, response.body)
        resultset.map do |record|
          record['DATABASE_NAME']
        end
      end
    end
  end
end
