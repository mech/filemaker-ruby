require 'faraday'
require 'typhoeus/adapters/faraday'

module Filemaker
  # @api private
  class Configuration < Struct.new(
      :host,
      :account_name,
      :password,
      :ssl,
      :log_curl,
      :log_metric
    )

    def not_configurable?
      host_missing? || account_name_missing? || password_missing?
    end

    %w(host account_name password).each do |name|
      define_method "#{name}_missing?" do
        (send(name.to_sym) || '').empty?
      end
    end

    def connection_options
      ssl.is_a?(Hash) ? { ssl: ssl } : {}
    end
  end

  class Server
    extend Forwardable

    # @return [Faraday::Connection] the HTTP connection
    attr_reader :connection

    # @return [Filemaker::Store::DatabaseStore] the database store
    attr_reader :databases
    alias_method :database, :databases
    alias_method :db, :databases

    def_delegators :@config, :host, :account_name, :password, :ssl

    def initialize(options = {})
      @config = Configuration.new
      yield @config if block_given?
      fail ArgumentError if @config.not_configurable?

      @databases = Store::DatabaseStore.new(self)
      @connection = get_connection(options)
    end

    # @api private
    # Mostly used by Filemaker::Api
    # TODO: There must be tracing. CURL etc. Or performance metrics?
    def perform_request(method, params = nil)
      @connection.__send__(method, '/fmi/xml/fmresultset.xml', params)
    end

    def handler_names
      @connection.builder.handlers.map(&:name)
    end

    private

    def get_connection(options = {})
      faraday_options = @config.connection_options.merge(options)

      Faraday.new(@config.host, faraday_options) do |faraday|
        faraday.request :url_encoded
        faraday.adapter :typhoeus
        faraday.headers[:user_agent] = \
          "filemaker-ruby-#{Filemaker::VERSION}".freeze
        faraday.basic_auth @config.account_name, @config.password
        # faraday.use XmlResponseHandler
      end
    end
  end
end

class XmlResponseHandler < Faraday::Response::Middleware
  require 'nokogiri'

  # Parse the incoming XML and return a Resultset array
  def parse(body)
    doc = Nokogiri::XML(body)
    doc.remove_namespaces!

    {
      error_code: doc.xpath('/fmresultset/error'),
      datasource: doc.xpath('/fmresultset/datasource'),
      meta: doc.xpath('/fmresultset/metadata'),
      resultset: doc.xpath('/fmresultset/resultset')
    }

    # Handle error here quickly!
  end
end
