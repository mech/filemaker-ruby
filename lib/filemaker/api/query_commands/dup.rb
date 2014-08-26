module Filemaker
  module Api
    module QueryCommands
      # Duplicate record.
      #
      # -recid
      # -script
      # -script.param
      # -relatedsets.filter
      # -relatedsets.max
      #
      def dup(id, options = {})
        valid_options(options,
                      :script,
                      :relatedsets_filter,
                      :relatedsets_max)

        perform_request('-dup', { '-recid' => id }, options)
      end
    end
  end
end
