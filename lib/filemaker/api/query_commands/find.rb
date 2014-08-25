module Filemaker
  module Api
    module QueryCommands
      # Find record(s).
      #
      # -max
      # -skip
      # -sortfield.[1-9]
      # -sortorder.[1-9]
      # -fieldname
      # -fieldname.op
      # -lop
      # -recid
      # -lay.response
      # -script
      # -script.param
      # -script.prefind
      # -script.prefind.param
      # -script.presort
      # -script.presort.param
      # -relatedsets.filter
      # -relatedsets.max
      #
      def find(id_or_hash, options = {})
        valid_options(options,
                      :max,
                      :skip,
                      :sortfield,
                      :sortorder,
                      :lop,
                      :lay_response,
                      :script,
                      :script_prefind,
                      :script_presort,
                      :relatedsets_filter,
                      :relatedsets_max)

        if id_or_hash.is_a? Hash
          perform_request('-find', id_or_hash, options)
        else
          perform_request('-find', { '-recid' => id_or_hash.to_s }, options)
        end
      end
    end
  end
end
