require 'filemaker/model/relations/proxy'

module Filemaker
  module Model
    module Relations
      class BelongsTo < Proxy
        def initialize(owner, name, options)
          super(owner, name, options)
          build_target
        end

        def reference_key
          options.fetch(:reference_key) { "#{@name}_id" }
        end

        def source_key
          options.fetch(:source_key) { nil }
        end

        def reference_value
          owner.public_send(reference_key.to_sym)
        end

        # Order: source_key first, reference_key next, then identity
        # all must be findable using `to find_field_by_name`
        def final_reference_key
          target_class.find_field_by_name(source_key).try(:name) ||
            target_class.find_field_by_name(reference_key).try(:name) ||
            target_class.identity.try(:name)
        end

        protected

        # Single `=` match whole word or (match empty)
        # Double `==` match entire field
        # If the field value contains underscore or space like 'FM_notified'
        # or 'FM notified', a single `=` may not match correctly.
        def build_target
          @target = nil if reference_value.blank? || final_reference_key.blank?

          @target = target_class.where(
            final_reference_key => "=#{reference_value}"
          ).first
        end
      end
    end
  end
end
