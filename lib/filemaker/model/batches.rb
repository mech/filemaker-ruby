module Filemaker
  module Model
    module Batches
      def in_batches(batch_size: 200, options: {})
        output = []
        total = where(options).count
        pages = (total / batch_size.to_f).ceil
        1.upto(pages) do |page|
          output.concat where(options).per(batch_size).page(page).all
        end

        output
      end
    end
  end
end
