require 'filemaker/model/relations/proxy'

module Filemaker
  module Model
    module Relations
      class HasMany < Proxy
        def initialize(owner, name, options)
          super(owner, name, options)
          build_target
        end

        # If no reference_key, we will use owner's identity field. If there is
        # no identity, we wil...??
        def reference_key
          options.fetch(:reference_key) { owner.identity.name }
        end

        def build_target
          key_value = owner.public_send(reference_key.to_sym)

          if key_value.blank?
            @target = nil # Or should we return empty array?
          else
            @target = target_class.where(reference_key => "=#{key_value}")
          end
        end
      end
    end
  end
end
