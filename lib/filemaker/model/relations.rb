require 'filemaker/model/relations/belongs_to'

module Filemaker
  module Model
    module Relations
      extend ActiveSupport::Concern

      included do
        attr_reader :relations
      end

      module ClassMethods
        def has_many(name, options = {})
          Relations::HasMany.new(self, name, options)
        end

        def belongs_to(name, options = {})
          relate_single(Relations::BelongsTo, name, options)
        end

        def has_portal(name, options = {})
          Relations::HasPortal.new(self, name, options)
        end

        protected

        def relate_single(type, name, options)
          name = name.to_s

          define_method(name) do
            @relations[name] ||= type.new(self, name, options)
          end
        end

        def relate_collection(type, name, options)
        end
      end
    end
  end
end
