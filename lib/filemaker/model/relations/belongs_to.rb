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
            @target = target_class.where(reference_key => "=#{key_value}").first
          end
        end
      end
    end
  end
end
