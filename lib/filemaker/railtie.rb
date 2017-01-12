require 'rails'

module Rails
  module Filemaker
    class Railtie < Rails::Railtie
      initializer 'filemaker-load-config-yml' do
        config_file = Rails.root.join('config', 'filemaker.yml')

        unless config_file.file?
          raise ::Filemaker::Errors::ConfigurationError, 'No config file'
        end

        ::Filemaker.load!(config_file, Rails.env)
      end
    end
  end
end
