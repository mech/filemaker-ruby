require 'filemaker/model/relations/belongs_to'
require 'filemaker/model/relations/has_many'

module Filemaker
  module Model
    # Model relationships such as has_many, belongs_to, and has_portal.
    module Relations
      extend ActiveSupport::Concern

      included do
        attr_reader :relations
      end

      module ClassMethods
        def has_many(name, options = {})
          relate_collection(Relations::HasMany, name, options)
        end

        def belongs_to(name, options = {})
          relate_single(Relations::BelongsTo, name, options)
        end

        def has_portal(name, options = {})
          Relations::HasPortal.new(self, name, options)
        end

        protected

        # Get the single model and cache it to `relations`
        def relate_single(type, name, options)
          name = name.to_s

          define_method(name) do
            @relations[name] ||= type.new(self, name, options)
          end
        end

        # For collection, we will return criteria and not cache anything.
        def relate_collection(type, name, options)
          name = name.to_s

          define_method(name) do
            type.new(self, name, options)
          end
        end
      end
    end
  end
end
