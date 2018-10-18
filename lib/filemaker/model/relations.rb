require 'filemaker/model/relations/belongs_to'
require 'filemaker/model/relations/has_many'
require 'filemaker/model/relations/has_portal'

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
          relate_portal(Relations::HasPortal, name, options)
        end

        protected

        def relate_portal(type, name, options)
          name = name.to_s

          define_method(name) do
            type.new(self, name, options)
          end
        end

        # Get the single model and cache it to `relations`
        def relate_single(type, name, options)
          name = name.to_s

          # Reader
          #
          # @example Reload the record
          #   job.company(true)
          define_method(name) do |force_reload = false|
            if force_reload
              @relations[name] = type.init(self, name, options)
            else
              @relations[name] ||= type.init(self, name, options)
            end
          end

          # Writer
          #
          # TODO: What happen if `object` is brand new? We would want to save
          # the child as well as the parent. We need to wait for the child to
          # save and return the identity ID, then we update the parent's
          # reference_key.
          define_method("#{name}=") do |object|
            return nil if object.nil?

            params = { "#{name}_id" => object.public_send("#{name}_id") }
            update_attributes(params)
          end

          # Creator
          # define_method("create_#{name}") do |attrs = {}|
          # end
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
