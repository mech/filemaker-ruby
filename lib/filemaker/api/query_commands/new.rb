module Filemaker
  module Api
    module QueryCommands
      # Add new record.
      #
      # -script
      # -script.param
      # -relatedsets.filter
      # -relatedsets.max
      #
      def new(values, options = {})
        perform_request('-new', values, options)
      end
    end
  end
end
