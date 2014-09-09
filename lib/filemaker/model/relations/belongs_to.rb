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

        def build_target
          key_value = owner.public_send(reference_key.to_sym)

          if key_value.blank?
            @target = nil
          else
            query_param = {
              reference_key => "=#{owner.public_send(reference_key.to_sym)}"
            }

            @target = target_class.where(query_param).first
          end
        end
      end
    end
  end
end
