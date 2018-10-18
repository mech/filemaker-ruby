module Filemaker
  module Model
    module Relations
      # A proxy is a class to send all unknown methods to it's target. The
      # target here will be the eventual associated model.
      class Proxy
        instance_methods.each do |method|
          undef_method(method) unless
            method =~ /^(__.*|send|object_id|equal\?|respond_to\?|tap|public_send)$/
        end

        attr_accessor :owner, :target, :options

        # @param [Filemaker::Layout] owner The instance of the model
        # @param [String] name The relationship name
        # @param [Hash] options Relationship options
        def initialize(owner, name, options)
          @owner = owner
          @name = name
          @options = options
          @class_name = options.fetch(:class_name) { name.to_s.classify }
        end

        # Create will not return the proxy if target was NilClass
        def self.init(owner, name, options)
          new_instance = new(owner, name, options)
          new_instance.target.nil? ? nil : new_instance
        end

        def target_class
          return @class_name if @class_name.is_a?(Class)

          @class_name.constantize
        end

        # Rubocop will complain and ask to fallback on `super`, but we won't be
        # able to do that because the target may have method that throw
        # exception
        def method_missing(name, *args, &block)
          target.send(name, *args, &block)
        end

        def respond_to_missing?(method_name, include_private = false)
          super
        end
      end
    end
  end
end
