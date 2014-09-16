require 'filemaker/model/relations/proxy'

module Filemaker
  module Model
    module Relations
      class HasPortal < Proxy
        def initialize(owner, name, options)
          super(owner, name, options)
          build_target
        end

        def table_name
          options.fetch(:table_name)
        end

        protected

        def build_target
          @target = owner.portals[table_name]
        end
      end
    end
  end
end
