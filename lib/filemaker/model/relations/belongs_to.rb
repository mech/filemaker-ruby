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

        protected

        def build_target
          key_value = owner.public_send(reference_key.to_sym)

          if key_value.blank?
            @target = nil
          else
            # Single `=` match whole word or (match empty)
            # Double `==` match entire field
            # If the field value contains underscore or space like 'FM_notified'
            # or 'FM notified', a single `=` may not match correctly.

            # If default reference_key is actually not defined at target_class
            # we will try to find identity
            reference_key = target_class.find_field_by_name(reference_key) ||
                            target_class.identity.try(:name)

            if reference_key
              @target = target_class.where(reference_key => "=#{key_value}").first
            else
              @target = nil
            end
          end
        end
      end
    end
  end
end
