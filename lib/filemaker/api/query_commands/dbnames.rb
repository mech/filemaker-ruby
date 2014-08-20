module Filemaker
  module Api
    module QueryCommands
      # Using -dbnames command to get all the available databases from Filemaker
      # server. Based on permission, the list may not be complete.
      def dbnames
        response = @server.perform_request(:get, { '-dbnames' => '' })
        response.body[:resultset].xpath('record/field/data').map(&:text)

        # Filemaker::Resultset.new(@server, response.body)
      end
    end
  end
end
