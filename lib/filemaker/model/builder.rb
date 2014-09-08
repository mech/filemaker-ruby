module Filemaker
  module Model
    module Builder
      module_function

      # Given an array of resultset, build out the exact same number of model
      # objects.
      def collection(resultset, klass)
        models = []

        resultset.each do |record|
          object = klass.new

          object.instance_variable_set('@new_record', false)
          object.instance_variable_set('@record_id', record.record_id)
          object.instance_variable_set('@mod_id', record.mod_id)

          record.keys.each do |fm_field_name|
            # record.keys are all lowercase
            field = klass.find_field_by_name(fm_field_name)
            next unless field

            object.public_send("#{field.name}=", record[fm_field_name])
          end

          models << object
        end

        models
      end
    end
  end
end
