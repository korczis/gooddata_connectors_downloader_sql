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

          def load_db_fields(entity_name)
            raise Exception, "The method need to be implemented by child"
          end

          def download_data(entity_name,entity_field_ids)
            CSV.open("tmp/#{entity_name}.csv",'w',:write_headers=> true,:headers => entity_field_ids ) do |csv|
              @db[entity_name.to_sym].each do |row|
                csv << entity_field_ids.map{|field_id| row[field_id.downcase.to_sym] }
              end
            end
            gzip = "tmp/#{entity_name}.csv.gz"
            orig = "tmp/#{entity_name}.csv"
            Zlib::GzipWriter.open(gzip) do |gz|
              gz.mtime = File.mtime(orig)
              gz.orig_name = File.basename(orig)
              gz.write IO.binread(orig)
            end
            gzip
          end


        end
      end
    end
  end
end
