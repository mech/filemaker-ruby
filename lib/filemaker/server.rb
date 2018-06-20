require 'typhoeus'
require 'filemaker/configuration'

module Filemaker
  class Server
    extend Forwardable

    # @return [Filemaker::Store::DatabaseStore] the database store
    attr_reader :databases
    alias database databases
    alias db databases

    def_delegators :@config, :host, :url, :endpoint, :log
    def_delegators :@config, :account_name, :password
    def_delegators :@config, :ssl_verifypeer, :ssl_verifyhost, :ssl, :timeout

    def initialize
      @config = Configuration.new
      yield @config if block_given?
      raise ArgumentError, 'Missing config block' if @config.not_configurable?

      @databases = Store::DatabaseStore.new(self)
    end

    # @api private
    # Mostly used by Filemaker::Api
    # TODO: There must be tracing/instrumentation. CURL etc.
    # Or performance metrics?
    # Also we want to pass in timeout option so we can ignore timeout for really
    # long requests
    #
    # @return [Array] response and request params Hash
    def perform_request(action, args, options = {})
      params = serialize_args(args)
               .merge(expand_options(options))
               .merge({ action => '' })

      # Serialize the params for submission??
      params.stringify_keys!

      log_action(params)

      # yield params if block_given?

      response = Typhoeus.post(
        "#{url}#{endpoint}",
        ssl_verifypeer: ssl_verifypeer,
        ssl_verifyhost: ssl_verifyhost,
        userpwd: "#{account_name}:#{password}",
        body: params
      )

      case response.response_code
      when 200
        [response, params]
      when 401
        raise Errors::AuthenticationError,
              "[#{response.response_code}] Authentication failed."
      when 0
        raise Errors::CommunicationError,
              "[#{response.response_code}] Empty response."
      when 404
        raise Errors::CommunicationError,
              "[#{response.response_code}] Not found"
      when 302
        raise Errors::CommunicationError,
              "[#{response.response_code}] Redirect not supported"
      when 502
        raise Errors::CommunicationError,
              "[#{response.response_code}] Bad gateway. Too many records."
      else
        msg = "Unknown response code = #{response.response_code}"
        raise Errors::CommunicationError, msg
      end
    end

    def handler_names
      @connection.builder.handlers.map(&:name)
    end

    private

    def get_typhoeus_connection(body)
      request = Typhoeus::Request.new(
        "#{url}#{endpoint}",
        method: :post,
        ssl_verifypeer: ssl_verifypeer,
        ssl_verifyhost: ssl_verifyhost,
        userpwd: "#{account_name}:#{password}",
        body: body,
        timeout: timeout || 0
      )

      request.run
    end

    # {"-db"=>"mydb", "-lay"=>"mylay", "email"=>"a@b.com", "updated_at": Date}
    # Take Ruby type and serialize into a form FileMaker can understand
    def serialize_args(args)
      return {} if args.nil?

      args.each do |key, value|
        case value
        when DateTime
          args[key] = value.strftime('%m/%d/%Y %H:%M:%S')
        when Date
          args[key] = value.strftime('%m/%d/%Y')
        when Time
          args[key] = value.strftime('%H:%M')
        else
          # Especially for range operator (...), we want to output as String
          args[key] = value.to_s
        end
      end

      args
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
            raise(Filemaker::Errors::ParameterError, msg) if value.size > 9
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
            raise(Filemaker::Errors::ParameterError, msg) if value.size > 9
            options[:sortfield].each_index do |index|
              expanded["-sortorder.#{index + 1}"] = value[index] || 'ascend'
            end
          else
            expanded['-sortorder.1'] = value
          end
        when :lay_response
          expanded['-lay.response'] = value
        when :lop
          expanded['-lop'] = value
        when :modid
          expanded['-modid'] = value
        when :relatedsets_filter
          expanded['-relatedsets.filter'] = value
        when :relatedsets_max
          expanded['-relatedsets.max'] = value
        when :delete_related
          expanded['-delete.related'] = value
        when :script
          if value.is_a? Array
            expanded['-script'] = value[0]
            expanded['-script.param'] = value[1]
          else
            expanded['-script'] = value
          end
        when :script_prefind
          if value.is_a? Array
            expanded['-script.prefind'] = value[0]
            expanded['-script.prefind.param'] = value[1]
          else
            expanded['-script.prefind'] = value
          end
        when :script_presort
          if value.is_a? Array
            expanded['-script.presort'] = value[0]
            expanded['-script.presort.param'] = value[1]
          else
            expanded['-script.presort'] = value
          end
        end
      end

      expanded
    end

    # TODO: Should we convert it to string so 'cURL' will work also?
    def log_action(params)
      case @config.log.to_s
      when 'simple'    then log_simple(params)
      when 'curl'      then log_curl(params)
      when 'curl_auth' then log_curl(params, true)
      end
    end

    def log_curl(params, has_auth = false)
      full_url        = "#{url}#{endpoint}?#{log_params(params)}"
      curl_ssl_option = ''
      auth            = ''

      curl_ssl_option = ' -k' if ssl.is_a?(Hash) && !ssl.fetch(:verify) { true }

      auth = " -H 'Authorization: #{@connection.headers['Authorization']}'" if \
        has_auth

      # warn 'Pretty print like so: `curl XXX | xmllint --format -`'
      warn "curl -XGET '#{full_url}'#{curl_ssl_option} -i#{auth}"
    end

    def log_simple(params)
      warn colorize('48;2;255;0;0', "#{endpoint}?#{log_params(params)}")
    end

    def log_params(params)
      params.map do |key, value|
        "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
      end.join('&')
    end

    def colorize(color, message)
      "\e[#{color}m#{message}\e[0m"
    end
  end
end
