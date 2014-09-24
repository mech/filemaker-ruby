module Filemaker
  module Elasticsearch
    module FilemakerAdapter
      module Records
        def records
          criteria = klass.in(klass.identity.name => ids)

          criteria.instance_exec(response.response['hits']['hits']) do |hits|
            define_singleton_method :to_a do
              self.entries.sort_by do |e|
                hits.index { |hit| hit['_id'].to_s == e.id.to_s }
              end
            end
          end

          criteria
        end
      end

      module Callbacks
        # noop
      end

      module Importing
      end
    end
  end
end
