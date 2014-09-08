module Filemaker
  module Model
    module Findable
      delegate \
        :limit,
        :skip,
        :order,
        :find,
        :first,
        :recid,
        :in,
        :not_in,
        :or,
        :eq,
        :cn,
        :bw,
        :ew,
        :gt,
        :gte,
        :lt,
        :lte,
        :neq,
        :equals,
        :contains,
        :begins_with,
        :ends_with,
        :not,
        :where, to: :criteria

      def criteria
        Criteria.new(self)
      end
    end
  end
end
