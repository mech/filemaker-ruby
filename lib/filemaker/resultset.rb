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

    # @param xml [String] the XML string from response
    def initialize(server, xml)
      @list = []
      @fields = {}
      @portal_fields = {}
      @server = server

      doc = Nokogiri::XML(xml)
      doc.remove_namespaces!

      error_code = doc.xpath('/fmresultset/error').attribute('code').value.to_i

      raise_potential_error!(error_code)

      datasource = doc.xpath('/fmresultset/datasource')
      metadata   = doc.xpath('/fmresultset/metadata')
      resultset  = doc.xpath('/fmresultset/resultset')
      records    = resultset.xpath('record')

      @date_format = convert_date_time_format(
        datasource.attribute('date-format').value
      )
      @time_format = convert_date_time_format(
        datasource.attribute('time-format').value
      )
      @timestamp_format = convert_date_time_format(
        datasource.attribute('timestamp-format').value
      )

      @count = resultset.attribute('count').value.to_i
      @total_count = datasource.attribute('total-count').value.to_i

      build_metadata(metadata)
      build_records(records)
    end

    # Delegate to list -> map, filter, reverse, etc
    def each(*args, &block)
      list.each(*args, &block)
    end

    private

    def raise_potential_error!(error_code)
      return if error_code.zero?

      fail
    end

    def build_metadata(metadata)
      metadata.xpath('field-definition').each do |definition|
        @fields[definition['name']] = Metadata::Field.new(definition, self)
      end

      metadata.xpath('relatedset-definition')
    end

    def build_records(records)
    end

    def convert_date_time_format(format)
      format
        .gsub('MM', '%m')
        .gsub('dd', '%d')
        .gsub('yyyy', '%Y')
        .gsub('HH', '%H')
        .gsub('mm', '%M')
        .gsub('ss', '%S')
    end

    def formatter
      {
        date_format: @date_format,
        time_format: @time_format,
        timestamp_format: @timestamp_format
      }
    end
  end
end
