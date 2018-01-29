module Filemaker
  module Model
    module Pagination
      # Calling `page` will trigger pagination.
      def page(value)
        value = 1 if value.nil?
        chains << :page
        @_page = positive_page(value.to_i)
        update_skip
        all
      end

      def per(value)
        limit(value)
        update_skip
      end

      # A simple getter to retrieve the current page value. If no one set it up
      # through the `page(4)` way, then at least it defaults to 1.
      def __page
        @_page || 1
      end

      # A simple getter to retrieve the limit value. It will default to
      # Model.per_page
      #
      # Will have stacklevel too deep if we have `per(nil)`. Somehow, the
      # `per_page` must be set either at the `Model.per_page`,
      # `Kaminari.config.default_per_page`, or right here where I just throw a
      # 25 value at it.
      def __per
        per(klass.per_page || 25) unless limit?
        options[:max]
      end

      def update_skip
        skip = (__page - 1) * __per
        skip(skip) unless skip.zero?
        self
      end

      def positive_page(page)
        return 1 if page.nil? || !page.is_a?(Integer)
        page.positive? ? page : 1
      end
    end
  end
end
