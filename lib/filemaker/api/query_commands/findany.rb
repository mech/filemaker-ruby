module Filemaker
  module Api
    module QueryCommands
      def findany(options = {})
        perform_request('-findany', {}, options)
      end
    end
  end
end
