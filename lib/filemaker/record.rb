module Filemaker
  class Record < HashWithIndifferentAndCaseInsensitiveAccess
    # @return [String] modification ID
    attr_reader :mod_id

    # @return [String] record ID that is used for -edit and -delete
    attr_reader :record_id

    # @return [Hash] additional nested records
    attr_reader :portals

    attr_reader :dirty

    def initialize(record, resultset, portal_table_name = nil)
      @mod_id    = record['mod-id']
      @record_id = record['record-id']
      @portals   = HashWithIndifferentAndCaseInsensitiveAccess.new
      @dirty     = {} # Keep track of field modification
      @ready     = false

      record.xpath('field').each do |field|
        # `field` is Nokogiri::XML::Element
        field_name = field['name']
        # Right now, I do not want to mess with the field name
        # field_name.gsub!(Regexp.new(portal_table_name + '::'), '')
        #   \if portal_table_name
        datum = []

        metadata_fields = if portal_table_name
                            resultset.portal_fields[portal_table_name]
                          else
                            resultset.fields
                          end

        field.xpath('data').each do |data|
          datum.push(metadata_fields[field_name].coerce(data.inner_text))
        end

        self[field_name] = normalize_data(datum)
      end

      build_portals(record.xpath('relatedset'), resultset)

      @ready = true
    end

    def [](key)
      fail(Filemaker::Error::InvalidFieldError, "Invalid field: #{key}") \
        unless key?(key)
      super
    end

    def []=(key, value)
      return super unless @ready
      fail(Filemaker::Error::InvalidFieldError, "Invalid field: #{key}") \
        unless key?(key)
      @dirty[key] = value
    end

    private

    def build_portals(relatedsets, resultset)
      return if relatedsets.empty?

      relatedsets.each do |relatedset|
        # `relatedset` is Nokogiri::XML::Element
        table_name = relatedset['table']
        records    = []

        relatedset.xpath('record').each do |record|
          records << self.class.new(record, resultset, table_name)
        end

        @portals[table_name] = records
      end
    end

    def normalize_data(datum)
      return nil if datum.empty?
      (datum.size == 1) ? datum.first : datum
    end

    def method_missing(symbol, *args, &block)
      method = symbol.to_s
      return self[method] if key?(method)
      return @dirty[$`] = args.first if method =~ /(=)$/ && key?($`)
      super
    end
  end
end
