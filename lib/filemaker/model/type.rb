require 'filemaker/model/types/text'
require 'filemaker/model/types/date'
require 'filemaker/model/types/time'
require 'filemaker/model/types/big_decimal'
require 'filemaker/model/types/integer'
require 'filemaker/model/types/email'
require 'filemaker/model/types/attachment'

module Filemaker
  module Model
    module Type
      @registry = {}

      class << self
        attr_accessor :registry

        def register(type_name, klass)
          registry[type_name] = klass
        end
      end

      register(:string, Filemaker::Model::Types::Text)
      register(:text, Filemaker::Model::Types::Text)
      register(:date, Filemaker::Model::Types::Date)
      register(:datetime, Filemaker::Model::Types::Time)
      register(:money, Filemaker::Model::Types::BigDecimal)
      register(:number, Filemaker::Model::Types::BigDecimal)
      register(:integer, Filemaker::Model::Types::Integer)
      register(:email, Filemaker::Model::Types::Email)
      register(:object, Filemaker::Model::Types::Attachment)
    end
  end
end
