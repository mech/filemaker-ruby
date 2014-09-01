module Filemaker
  # Give ActiveModel-like behaviors for easy Rails integration.
  module Model
    extend ActiveSupport::Concern
    include Fields

    included do
      class_attribute :db, :lay
    end

    def initialize(attrs = nil)
      @attributes ||= {}
      apply_defaults
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
