require 'filemaker/model/fields'
require 'filemaker/model/findable'
require 'filemaker/model/batches'
require 'filemaker/model/relations'
require 'filemaker/model/persistable'

module Filemaker
  module Model
    module Components
      extend ActiveSupport::Concern

      included do
        extend Findable
        extend Batches
        extend ActiveModel::Callbacks
      end

      # Includes Naming, Translation, Validations, Conversion and
      # AttributeAssignment
      include ActiveModel::Model

      include ActiveModel::Dirty
      include ActiveModel::Serializers::JSON

      # Provide before/after_validation
      include ActiveModel::Validations::Callbacks

      include GlobalID::Identification
      include Fields
      include Relations
      include Persistable
    end
  end
end
