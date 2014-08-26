module Filemaker
  module Api
    module QueryCommands
      # Delete record.
      #
      # -recid
      # -script
      # -script.param
      #
      def delete(id, options = {})
        valid_options(options, :script)
        perform_request('-delete', { '-recid' => id }, options)
      end
    end
  end
end
