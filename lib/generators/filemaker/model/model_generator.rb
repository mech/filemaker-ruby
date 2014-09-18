require 'rails/generators'

module Filemaker
  module Generators
    class ModelGenerator < ::Rails::Generators::NamedBase
      desc 'Create FileMaker model.'
      argument :db, type: :string, required: true
      argument :lay, type: :string, required: true
      argument :registry, type: :string, required: false

      def self.source_root
        @source_root ||= File.expand_path(
          File.join(File.dirname(__FILE__), 'templates')
        )
      end

      def create_model_file
        server = Filemaker.registry[registry || 'default']
        api = server.db[db][lay]
        @fields = api.view.fields.values.map do |field|
          [field.name, field.data_type]
        end

        @type_mappings = {
          'text' => 'string',
          'number' => 'number',
          'date' => 'date',
          'time' => 'datetime',
          'timestamp' => 'datetime'
        }

        template(
          'model.rb',
          File.join('app/models', class_path, "#{file_name}.rb")
        )
      end
    end
  end
end
