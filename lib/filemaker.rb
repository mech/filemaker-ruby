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

module Filemaker
  module_function

  # def load!(path_to_yaml)
  #   registry[:default] = Filemaker::Server.new do |config|
  #   end
  # end

  # def registry
  #   @registry ||= {}
  # end
end

require 'filemaker/railtie' if defined?(Rails)
