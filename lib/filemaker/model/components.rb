require 'filemaker/model/fields'
require 'filemaker/model/findable'
require 'filemaker/model/relations'
require 'filemaker/model/persistable'

module Filemaker
  module Model
    module Components
      extend ActiveSupport::Concern

      included do
        extend Findable
        extend ActiveModel::Callbacks
      end

      include ActiveModel::Model
      include ActiveModel::Serializers::JSON
      include ActiveModel::Serializers::Xml
      include ActiveModel::Validations::Callbacks
      include Fields
      include Relations
      include Persistable
      # include Serializable
    end
  end
end
