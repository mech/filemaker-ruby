module Filemaker
  module Api
    module QueryCommands
      # Find a random record.
      #
      # If data cannot be coerced, it will crash!
      # Acceptable params are:
      # -script
      # -script.param
      # -script.prefind
      # -script.prefind.param
      # -relatedsets.filter
      # -relatedsets.max
      #
      def findany(options = {})
        valid_options(options,
                      :script,
                      :script_prefind,
                      :relatedsets_filter,
                      :relatedsets_max)

        perform_request('-findany', {}, options)
      end
    end
  end
end
