require 'filemaker/model/components'

module Filemaker
  module Model
    extend ActiveSupport::Concern
    include Components

    attr_reader :new_record, :record_id, :mod_id, :portals

    included do
      class_attribute :db, :lay, :registry_name, :server, :api, :per_page
      self.per_page = Kaminari.config.default_per_page if defined?(Kaminari)
    end

    def initialize(attributes = {})
      # We did not manage to use `ActiveModel::AttributeAssignment`
      # super

      @new_record = true
      @relations = {}
      apply_defaults
      process_attributes(attributes)
    end

    def new_record?
      new_record
    end

    def persisted?
      !new_record?
    end

    def to_a
      [self]
    end

    def model_key
      @model_key ||= self.class.model_name.cache_key
    end

    def cache_key
      return "#{model_key}/new" if new_record?
      return "#{model_key}/#{id}-#{updated_at.to_datetime.utc.to_s(:number)}" \
        if respond_to?(:updated_at) && send(:updated_at)
      "#{model_key}/#{id}"
    end

    def id
      self.class.identity ? identity_id : record_id
    end

    def identity_id
      public_send(identity.name) if identity
    end

    def to_param
      id&.to_s
    end

    def fm_attributes
      self.class.with_model_fields(attributes)
    end

    def dirty_attributes
      dirty = {}
      changed.each do |attr_name|
        dirty[attr_name] = attributes[attr_name]
      end
      self.class.with_model_fields(dirty)
    end

    private

    def process_attributes(attributes)
      return if attributes.empty?

      attributes.each_pair do |key, value|
        setter = :"#{key}="
        public_send(setter, value) if respond_to?(setter)
      end
    end

    module ClassMethods
      def database(db)
        self.db = db
        self.registry_name ||= 'default' unless lay.blank?
        register
      end

      def layout(lay)
        self.lay = lay
        self.registry_name ||= 'default' unless db.blank?
        register
      end

      def registry(name)
        self.registry_name = (name || 'default').to_s
        register
      end

      def register
        self.server = Filemaker.registry[registry_name]
        self.api = server.db[db][lay] if server && db && lay
      end

      # A chance for the model to set it's per_page.
      def paginates_per(value)
        self.per_page = value.to_i
      end

      def default_per_page
        per_page
      end

      # Make use of -view to return an array of [name, data_type] for this
      # model from FileMaker.
      #
      # @return [Array] array of [name, data_type]
      def fm_fields
        api.view.fields.values.map { |field| [field.name, field.data_type] }
      end

      # Filter out any fields that do not match model's fields.
      #
      # A testing story to tell: when working on `in` query, we have value that
      # is an array. Without the test and expectation setup, debugging the
      # output will take far longer to realise. This reinforce the belief that
      # TDD is in fact a valuable thing to do.
      def with_model_fields(criterion, coerce = true)
        accepted_fields = {}

        criterion.each_pair do |key, value|
          field = find_field_by_name(key)

          # Do not process nil value, but empty string is ok in order to reset
          # some fields.
          next unless field && value

          # We do not serialize at this point, as we are still in Ruby-land.
          # Filemaker::Server will help us serialize into FileMaker format.
          if value.is_a? Array
            temp = []
            value.each do |v|
              temp << (coerce ? field.coerce(v) : v)
            end

            accepted_fields[field.fm_name] = temp
          else
            accepted_fields[field.fm_name] = \
              coerce ? field.coerce(value) : value
          end
        end

        accepted_fields
      end
    end
  end
end
