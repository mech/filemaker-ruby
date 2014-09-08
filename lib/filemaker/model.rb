require 'filemaker/model/components'

module Filemaker
  module Model
    extend ActiveSupport::Concern
    include Components

    # @return [Boolean] indicates if this is a new fresh record
    attr_reader :new_record, :record_id, :mod_id

    included do
      class_attribute :db, :lay, :registry_name, :server, :api
    end

    def initialize(attrs = nil)
      @new_record = true
      @attributes = {}
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
    end
  end
end
