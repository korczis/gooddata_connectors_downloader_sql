# encoding: utf-8

module GoodData
  module Connectors
    module DownloaderSql
      module Backend
        class BaseBackend
          attr_reader :connection_options,:db

          def initialize(opts = {})
            @connection_options = opts
          end

          def create_connection
            raise Exception, "The method need to be implemented by child"
          end

          def download_entity(entity_name,entity_field_ids)
            CSV.open('test.csv','w',:write_headers=> true,:headers => entity_field_ids ) do |csv|
              @db[entity_name.to_sym].each do |row|
                csv << entity_field_ids.map{|field_id| row[field_id.downcase.to_sym] }
              end
            end
          end


        end
      end
    end
  end
end
