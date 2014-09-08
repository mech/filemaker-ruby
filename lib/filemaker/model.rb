require 'filemaker/model/components'

module Filemaker
  module Model
    extend ActiveSupport::Concern
    include Components

    # @return [Boolean] indicates if this is a new fresh record
    attr_reader :new_record

    # @return [Filemaker::Layout] the raw API for you to make low-level call
    attr_reader :api

    included do
      class_attribute :db, :lay, :registry_name
    end

    def initialize(attrs = nil)
      @new_record = true
      @attributes = {}
      apply_defaults
      process_attributes(attrs)

      @server = Filemaker.registry[(registry_name || 'default').to_s]
      @api = @server.db[db][lay]
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
      end

      def layout(lay)
        self.lay = lay
      end

      def registry(name)
        self.registry_name = name
      end
    end
  end
end
