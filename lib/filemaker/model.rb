require 'filemaker/model/components'

module Filemaker
  module Model
    extend ActiveSupport::Concern
    include Components

    # @return [Boolean] indicates if this is a new fresh record
    attr_reader :attributes, :new_record, :record_id, :mod_id

    included do
      class_attribute :db, :lay, :registry_name, :server, :api, :per_page
      self.per_page = Kaminari.config.default_per_page if defined?(Kaminari)
    end

    def initialize(attrs = nil)
      @new_record = true
      @attributes = {}
      @relations = {}
      apply_defaults
      process_attributes(attrs)
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

    def id
      self.class.identity ? identity_id : record_id
    end

    def identity_id
      public_send(identity.name) if identity
    end

    def to_param
      id.to_s if id
    end

    def fm_attributes
      self.class.with_model_fields(attributes)
    end

    private

    def process_attributes(attrs)
      attrs ||= {}
      return if attrs.empty?

      attrs.each_pair do |key, value|
        public_send("#{key}=", value) if respond_to?("#{key}=")
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
