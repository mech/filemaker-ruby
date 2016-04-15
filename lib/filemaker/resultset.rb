require 'nokogiri'
require 'filemaker/metadata/field'

module Filemaker
  class Resultset
    include Enumerable

    # @return [Array] hold records
    attr_reader :list

    # @return [Integer] number of records
    attr_reader :count

    # @return [Integer] total count of the record
    attr_reader :total_count

    # @return [Hash] representing the top-level non-portal field-definition
    attr_reader :fields

    # @return [Hash] representing the portal field-definition
    attr_reader :portal_fields

    # @return [String] Ruby's date format directive
    attr_reader :date_format

    # @return [String] Ruby's time format directive
    attr_reader :time_format

    # @return [String] Ruby's date and time format directive
    attr_reader :timestamp_format

    # @return [Filemaker::Server] the server
    attr_reader :server

    # @return [Hash] the request params
    attr_reader :params

    # @return [String] the raw XML for inspection
    attr_reader :xml

    # @param [Filemaker::Server] server
    # @param [String] xml The XML string from response
    # @param [Hash] params The request params used to construct request
    def initialize(server, xml, params = nil)
      @list = []
      @fields = {}
      @portal_fields = {}
      @server = server
      @params = params # Useful for debugging

      doc = Nokogiri::XML(xml).remove_namespaces!
      @xml = doc.to_xml(indent: 2) # Just want to pretty print it

      error_code = doc.xpath('/fmresultset/error').attribute('code').value.to_i
      raise_potential_error!(error_code)

      datasource = doc.xpath('/fmresultset/datasource')
      metadata   = doc.xpath('/fmresultset/metadata')
      resultset  = doc.xpath('/fmresultset/resultset')
      records    = resultset.xpath('record')

      @date_format = convert_format(datasource.attribute('date-format').value)
      @time_format = convert_format(datasource.attribute('time-format').value)
      @timestamp_format = \
        convert_format(datasource.attribute('timestamp-format').value)

      @count = resultset.attribute('count').value.to_i
      @total_count = datasource.attribute('total-count').value.to_i

      build_metadata(metadata)
      build_records(records)
    end

    # Delegate to list -> map, filter, reverse, etc
    def each(*args, &block)
      list.each(*args, &block)
    end

    def size
      list.size
    end
    alias_method :length, :size

    private

    # For 401 (No records match the request) and 101 (Record is missing), we
    # will return empty array or nil back rather than raise those errors. Is it
    # a good design? We need to find out after production usage.
    def raise_potential_error!(error_code)
      return if error_code.zero? || error_code == 401 || error_code == 101

      Filemaker::Errors.raise_error_by_code(error_code)
    end

    def build_metadata(metadata)
      metadata.xpath('field-definition').each do |definition|
        @fields[definition['name']] = Metadata::Field.new(definition, self)
      end

      metadata.xpath('relatedset-definition').each do |relatedset|
        table_name = relatedset.attribute('table').value
        p_fields   = {}

        @portal_fields[table_name] ||= p_fields

        relatedset.xpath('field-definition').each do |definition|
          # Right now, I do not want to mess with the field name
          # name = definition['name'].gsub("#{table_name}::", '')
          name = definition['name']
          @portal_fields[table_name][name] = \
            Metadata::Field.new(definition, self)
        end
      end
    end

    def build_records(records)
      records.each do |record|
        # record is Nokogiri::XML::Element
        list << Filemaker::Record.new(record, self)
      end
    end

    def convert_format(format)
      format
        .gsub('MM', '%m')
        .gsub('dd', '%d')
        .gsub('yyyy', '%Y')
        .gsub('HH', '%H')
        .gsub('mm', '%M')
        .gsub('ss', '%S')
    end
  end
end
