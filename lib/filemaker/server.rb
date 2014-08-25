require 'faraday'
require 'typhoeus/adapters/faraday'
require 'filemaker/configuration'

module Filemaker
  class Server
    extend Forwardable

    # @return [Faraday::Connection] the HTTP connection
    attr_reader :connection

    # @return [Filemaker::Store::DatabaseStore] the database store
    attr_reader :databases
    alias_method :database, :databases
    alias_method :db, :databases

    def_delegators :@config, :host, :url, :ssl, :endpoint
    def_delegators :@config, :account_name, :password

    def initialize(options = {})
      @config = Configuration.new
      yield @config if block_given?
      fail ArgumentError if @config.not_configurable?

      @databases = Store::DatabaseStore.new(self)
      @connection = get_connection(options)
    end

    # @api private
    # Mostly used by Filemaker::Api
    # TODO: There must be tracing/instrumentation. CURL etc.
    # Or performance metrics?
    # Also we want to pass in timeout option so we can ignore timeout for really
    # long requests
    #
    # @return [Array] Faraday::Response and request params Hash
    def perform_request(method, action, args, options = {})
      params = (args || {})
        .merge(expand_options(options))
        .merge({ action => '' })

      log_action(params)

      # yield params if block_given?
      response = @connection.__send__(method, endpoint, params)

      case response.status
      when 200 then [response, params]
      when 401 then fail Error::AuthenticationError, 'Auth failed.'
      when 0   then fail Error::CommunicationError, 'Empty response.'
      when 404 then fail Error::CommunicationError, 'HTTP 404 Not Found'
      else
        msg = "Unknown response status = #{response.status}"
        fail Error::CommunicationError, msg
      end
    end

    def handler_names
      @connection.builder.handlers.map(&:name)
    end

    private

    def get_connection(options = {})
      faraday_options = @config.connection_options.merge(options)

      Faraday.new(@config.url, faraday_options) do |faraday|
        faraday.request :url_encoded
        faraday.adapter :typhoeus
        faraday.headers[:user_agent] = \
          "filemaker-ruby-#{Filemaker::VERSION}".freeze
        faraday.basic_auth @config.account_name, @config.password
      end
    end

    def expand_options(options)
      expanded = {}
      options.each do |key, value|
        case key
        when :max
          expanded['-max'] = value
        when :skip
          expanded['-skip'] = value
        when :sortfield
          if value.is_a? Array
            msg = 'Too many sortfield, limit=9'
            fail(Filemaker::Error::ParameterError, msg) if value.size > 9
            value.each_index do |index|
              expanded["-sortfield.#{index + 1}"] = value[index]
            end
          else
            expanded['-sortfield.1'] = value
          end
        when :sortorder
          if value.is_a? Array
            # Use :sortfield as single source of truth for array size
            msg = 'Too many sortorder, limit=9'
            fail(Filemaker::Error::ParameterError, msg) if value.size > 9
            options[:sortfield].each_index do |index|
              expanded["-sortorder.#{index + 1}"] = value[index] || 'ascend'
            end
          else
            expanded['-sortorder.1'] = value
          end
        end
      end

      expanded
    end

    def log_action(params)
      case @config.log
      when :simple    then log_simple(params)
      when :curl      then log_curl(params)
      when :curl_auth then log_curl(params, true)
      else
        return
      end
    end

    def log_curl(params, has_auth = false)
      full_url = "#{url}#{endpoint}?#{log_params(params)}"
      curl_ssl_option, auth = '', ''

      curl_ssl_option = ' -k' if ssl.is_a?(Hash) && !ssl.fetch(:verify) { true }

      auth = " -H 'Authorization: #{@connection.headers['Authorization']}'" if \
        has_auth

      warn 'Pretty print like so: `curl XXX | xmllint --format -`'
      warn "curl -XGET '#{full_url}'#{curl_ssl_option} -i#{auth}"
    end

    def log_simple(params)
      warn "#{endpoint}?#{log_params(params)}"
    end

    def log_params(params)
      params.map do |key, value|
        "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
      end.join('&')
    end
  end
end
