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
            @target = target_class.where(reference_key => "=#{key_value}").first
          end
        end
      end
    end
  end
end
