module Filemaker
  module Model
    module Batches
      def in_batches(batch_size: 200, options: {}, include: {}, omit: nil, sleep: 0)
        output = []

        if options.present?
          include = options
          warn "Using `options` is deprecated. Please use `include` instead"
        end

        total = if omit
          self.in(include).not_in(omit).count
        else
          self.in(include).count
        end

        pages = (total / batch_size.to_f).ceil

        1.upto(pages) do |page|
          sleep(sleep)

          if omit
            output.concat(self.in(include).not_in(omit).per(batch_size).page(page))
          else
            output.concat(self.in(include).per(batch_size).page(page))
          end
        end

        output
      end

      def where_batches(batch_size: 200, options: {}, include: {}, omit: nil, sleep: 0)
        output = []

        if options.present?
          include = options
          warn "Using `options` is deprecated. Please use `include` instead"
        end

        total = if omit
          where(include).not(omit).count
        else
          where(include).count
        end

        pages = (total / batch_size.to_f).ceil

        1.upto(pages) do |page|
          sleep(sleep)

          if omit
            output.concat(where(include).not(omit).per(batch_size).page(page))
          else
            output.concat(where(include).per(batch_size).page(page))
          end
        end

        output
      end
    end
  end
end
