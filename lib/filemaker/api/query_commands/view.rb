module Filemaker
  module Api
    module QueryCommands
      # Retrieves <metadata> section of XML.
      #
      def view
        perform_request('-view', {}, {})
      end
    end
  end
end
