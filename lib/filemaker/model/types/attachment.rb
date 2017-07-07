require 'net/http'
require 'mimemagic'

module Filemaker
  module Model
    module Types
      class Attachment
        attr_reader :_body, :content_type, :extension, :klass

        def initialize(value, klass)
          @value = value
          @klass = klass
        end

        def url
          @value.to_s
        end

        def file_extension
          # We need to use .path to eliminate query string
          File.extname(URI.parse(url).path)
        end

        def filename
          return if url.blank?
          File.basename(URI.parse(url).path)
        end

        def body
          return @_body if defined?(@_body)

          @_body = download_protected_file

          if !file_extension.blank?
            @content_type = MimeMagic.by_extension(file_extension)
            @extension = file_extension
          else
            mime_type = MimeMagic.by_magic(@_body)

            unless mime_type.blank?
              case mime_type.type.downcase
              when 'application/msword'
                @content_type = 'application/msword'
                @extension = '.doc'
              when 'application/pdf'
                @content_type = 'application/pdf'
                @extension = '.pdf'
              when 'application/x-ole-storage'
                @content_type = 'application/vnd.ms-excel'
                @extension = '.xls'
              when 'application/vnd.ms-excel'
                @content_type = 'application/vnd.ms-excel'
                @extension = '.xls'
              when 'image/jpeg'
                @content_type = 'image/jpeg'
                @extension = '.jpg'
              when 'image/png'
                @content_type = 'image/png'
                @extension = '.png'
              when 'application/vnd.oasis.opendocument.text'
                @content_type = 'application/vnd.oasis.opendocument.text'
                @extension = '.odt'
              else
                # No choice, we have to assign it somehow
                @content_type = mime_type.type
              end
            end
          end

          @_body
        end

        private

        def download_protected_file
          req = Net::HTTP::Get.new(url)
          req.basic_auth(klass.server.account_name, klass.server.password)
          res = Net::HTTP.new(klass.server.host, 80)
          res = res.start { |http| http.request(req) }

          res.body
        end
      end
    end
  end
end
