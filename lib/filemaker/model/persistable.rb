module Filemaker
  module Model
    module Persistable
      extend ActiveSupport::Concern

      included do
        define_model_callbacks :save, :create, :update, :destroy
      end

      # Call save! but do not raise error.
      def save
        save!
      rescue
        errors.add(:base) << $! # Does this works?
        nil
      end

      def save!
        run_callbacks :save do
          new_record? ? create : update
        end
      end

      def create
        return false unless valid?

        run_callbacks :create do
          options = {}
          yield options if block_given?
          resultset = api.new(fm_attributes, options)
          replace_new_data(resultset)
        end
        self
      end

      def update
        return false unless valid?

        run_callbacks :update do
          # Will raise `RecordModificationIdMismatchError` if does not match
          options = { modid: mod_id } # Always pass in?
          yield options if block_given?
          resultset = api.edit(record_id, fm_attributes, options)
          replace_new_data(resultset)
        end
        self
      end

      def update_attributes(attrs = {})
        return self if attrs.blank?
        assign_attributes(attrs)
        save
      end

      # Use -delete to remove the record backed by the model.
      # @return [Filemaker::Model] frozen instance
      def destroy
        return if new_record?

        run_callbacks :destroy do
          options = {}
          yield options if block_given?
          api.delete(record_id, options)
        end
        freeze
      end
      alias_method :delete, :destroy

      # If value is nil, we convert to empty string so it will get pick up by
      # `fm_attributes`
      def assign_attributes(new_attributes)
        return if new_attributes.blank?
        new_attributes.each_pair do |key, value|
          public_send("#{key}=", (value || '')) if respond_to?("#{key}=")
        end
      end

      private

      # If you have calculated field from FileMaker, it will be replaced.
      def replace_new_data(resultset)
        record = resultset.first

        @new_record = false
        @record_id = record.record_id
        @mod_id = record.mod_id

        record.keys.each do |fm_field_name|
          # record.keys are all lowercase
          field = self.class.find_field_by_name(fm_field_name)
          next unless field

          public_send("#{field.name}=", record[fm_field_name])
        end
      end
    end
  end
end
