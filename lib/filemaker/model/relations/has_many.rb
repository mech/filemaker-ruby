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
        # no identity, we will...??
        def reference_key
          options.fetch(:reference_key) { owner.identity.name }
        end

        # Append a model or array of models to the relation. Will set the owner
        # ID to the children.
        #
        # @example Append a model
        #   job.applicants << applicant
        #
        # @example Array of models
        #   job.applicants << [applicant_a, applicant_b, applicant_c]
        #
        # @param [Filemaker::Model, Array<Filemaker::Model>] *args
        def <<(*args)
          docs = args.flatten
          return concat(docs) if docs.size > 1
          if (doc = docs.first)
            create(doc)
          end
          self
        end
        alias_method :push, :<<

        # def concat(docs)
        #   # TODO: Find out how to do batch insert in FileMaker
        # end

        # Build a single model. The owner will be linked, but the record will
        # not be saved.
        #
        # @example Append a model
        #   job.applicants.build(name: 'Bob')
        #   job.save
        #
        # @param [Hash] attrs The attributes for the fields
        #
        # @return [Filemaker::Model] the actual model
        def build(attrs = {})
          attrs.merge!(owner.identity.name => owner.identity_id) if \
            owner.identity_id
          target_class.new(attrs)
        end

        # Same as `build`, except that it will be saved automatically.
        #
        # @return [Filemaker::Model] the actual saved model
        def create(attrs = {})
          build(attrs).save
        end

        protected

        def build_target
          key_value = owner.public_send(reference_key.to_sym)

          if key_value.blank?
            @target = nil # Or should we return empty array?
          else
            # Single `=` match whole word or (match empty)
            # Double `==` match entire field
            # If the field value contains underscore or space like 'FM_notified'
            # or 'FM notified', a single `=` may not match correctly.
            @target = target_class.where(reference_key => "=#{key_value}")
          end
        end
      end
    end
  end
end
