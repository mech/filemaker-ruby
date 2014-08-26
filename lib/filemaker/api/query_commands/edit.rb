module Filemaker
  module Api
    module QueryCommands
      # Edit record.
      #
      # -recid
      # -modid
      # -script
      # -script.param
      # -relatedsets.filter
      # -relatedsets.max
      # -delete.related
      #
      def edit(id, values, options = {})
        valid_options(options,
                      :modid,
                      :script,
                      :relatedsets_filter,
                      :relatedsets_max,
                      :delete_related)

        perform_request('-edit', { '-recid' => id }.merge(values), options)
      end
    end
  end
end
