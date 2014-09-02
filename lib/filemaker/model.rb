require 'filemaker/model/components'

module Filemaker
  module Model
    extend ActiveSupport::Concern
    include Components

    attr_reader :new_record

    included do
      class_attribute :db, :lay
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
      end

      def layout(lay)
        self.lay = lay
      end
    end
  end
end
