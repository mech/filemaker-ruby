module Filemaker
  module Api
    module QueryCommands
      # Find all records.
      # Acceptable params are:
      # -max
      # -skip
      # -sortfield.[1-9]
      # -sortorder.[1-9]
      # -script
      # -script.param
      # -script.prefind
      # -script.prefind.param
      # -script.presort
      # -script.presort.param
      # -relatedsets.filter
      #
      def findall(options = {})
        valid_options(options,
                      :max,
                      :skip,
                      :sortfield,
                      :sortorder,
                      :script,
                      :script_prefind,
                      :relatedsets_filter)

        perform_request('-findall', {}, options)
      end
    end
  end
end
