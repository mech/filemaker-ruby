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
      rescue StandardError => e
        errors.add(:base) << e.message # Does this works?
        false
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
          resultset = api.new(create_attributes, options)
          changes_applied
          replace_new_data(resultset)
        end
        self
      end

      def update
        return false unless valid?
        return true if changes.empty?

        run_callbacks :update do
          # Will raise `RecordModificationIdMismatchError` if does not match
          options = { modid: mod_id } # Always pass in?
          yield options if block_given?
          fm_attributes = Hash[ changes.map{ |key, value| [fields[key].fm_name, value[1]] } ]
          resultset = api.edit(record_id, fm_attributes, options)
          changes_applied
          replace_new_data(resultset)
        end
        self
      end

      def update_attributes(attrs = {})
        return self if attrs.blank?

        assign_attributes(attrs)
        save
      end

      def update_attributes!(attrs = {})
        return self if attrs.blank?

        assign_attributes(attrs)
        save!
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

      alias delete destroy

      # If value is nil, we convert to empty string so it will get pick up by
      # `fm_attributes`
      # def assign_attributes(new_attributes)
      #   return if new_attributes.blank?

      #   new_attributes.each_pair do |key, value|
      #     next unless respond_to?("#{key}=")

      #     public_send("#{key}=", (value || ''))
      #   end
      # end

      def reload!
        resultset = api.find(record_id)
        replace_new_data(resultset)
        self
      end

      private

      # If you have calculated field from FileMaker, it will be replaced.
      def replace_new_data(resultset)
        Filemaker::Model::Builder.build(resultset.first, self)
      end
    end
  end
end
