module Filemaker
  module Model
    module Batches
      def in_batches(batch_size: 200, options: {}, sleep: 0)
        output = []
        total = self.in(options).count
        pages = (total / batch_size.to_f).ceil
        1.upto(pages) do |page|
          sleep(sleep)
          output.concat self.in(options).per(batch_size).page(page)
        end

        output
      end

      def where_batches(batch_size: 200, options: {}, sleep: 0)
        output = []
        total = where(options).count
        pages = (total / batch_size.to_f).ceil
        1.upto(pages) do |page|
          sleep(sleep)
          output.concat where(options).per(batch_size).page(page)
        end

        output
      end
    end
  end
end
