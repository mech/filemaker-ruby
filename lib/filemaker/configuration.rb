module Filemaker
  class Configuration
    attr_accessor :host, :account_name, :password, :ssl, :endpoint
    attr_accessor :log

    def initialize
      @endpoint = '/fmi/xml/fmresultset.xml'
    end

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

    def url
      (ssl.is_a?(Hash) || ssl == true) ? "https://#{host}" : "http://#{host}"
    end
  end
end
