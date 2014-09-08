require 'filemaker/version'
require 'filemaker/core_ext/hash'
require 'filemaker/server'
require 'filemaker/api'
require 'filemaker/database'
require 'filemaker/store/database_store'
require 'filemaker/store/layout_store'
require 'filemaker/store/script_store'
require 'filemaker/resultset'
require 'filemaker/record'
require 'filemaker/layout'
require 'filemaker/script'
require 'filemaker/error'

require 'active_support'
require 'active_support/core_ext'
require 'active_model'

require 'filemaker/model/criteria'
require 'filemaker/model'

require 'yaml'

module Filemaker
  module_function

  # Based on the environment, register the server so we only ever have one
  # instance of Filemaker::Server per named session. The named session will be
  # defined at the `filemaker.yml` config file.
  def load!(path, environment = nil)
    sessions = YAML.load(ERB.new(File.new(path).read).result)[environment.to_s]
    fail Error::ConfigurationError, 'Environment wrong?' if sessions.nil?

    sessions.each_pair do |key, value|
      registry[key] = Filemaker::Server.new do |config|
        config.host = value.fetch('host') do
          fail Error::ConfigurationError, 'Missing config.host'
        end

        config.account_name = value.fetch('account_name') do
          fail Error::ConfigurationError, 'Missing config.account_name'
        end

        config.password = value.fetch('password') do
          fail Error::ConfigurationError, 'Missing config.password'
        end

        config.ssl = value['ssl'] if value['ssl']
        config.log = value['log'] if value['log']
        config.endpoint = value['endpoint'] if value['endpoint']
      end
    end
  end

  def registry
    @registry ||= {}
  end
end

require 'filemaker/railtie' if defined?(Rails)
