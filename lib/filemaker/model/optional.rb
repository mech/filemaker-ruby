module Filemaker
  module Model
    module Optional
      # Number of records to skip. For pagination.
      #
      # @param [Integer] value The number to skip.
      #
      # @return [Filemaker::Model::Criteria]
      def skip(value)
        return self if value.nil?
        options[:skip] = value.to_i
        self
      end

      # Limit the number of records returned.
      #
      # @param [Integer] value The number of records to return.
      #
      # @return [Filemaker::Model::Criteria]
      def limit(value)
        return self if value.nil?
        options[:max] = value.to_i
        self
      end

      # Order the records. Model field name will be converted to real FileMaker
      # field name.
      #
      # @example Sort is position aware!
      #   criteria.order('name desc, email')
      #
      # @param [String] value The sorting string
      #
      # @return [Filemaker::Model::Criteria]
      def order(value)
        return self if value.nil?
        sortfield = []
        sortorder = []
        sort_spec = value.split(',').map(&:strip)

        sort_spec.each do |spec|
          field, order = spec.split(' ')
          order = 'asc' unless order

          field = model.field_by_name(field)

          if field
            order = 'ascend' if order.downcase == 'asc'
            order = 'descend' if order.downcase == 'desc'

            sortfield << field.fm_name
            sortorder << order
          end
        end

        unless sortfield.empty?
          options[:sortfield] = sortfield
          options[:sortorder] = sortorder
        end

        self
      end
    end
  end
end
