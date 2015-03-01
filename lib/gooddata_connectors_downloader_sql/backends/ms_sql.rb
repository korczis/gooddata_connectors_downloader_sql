# encoding: utf-8

require_relative 'drivers/sqljdbc41.jar'

module GoodData
  module Connectors
    module DownloaderSql
      module Backend
        class MsSql < BaseBackend

          def create_connection
            @db = Sequel.connect("jdbc:sqlserver://#{@connection_options['server']};database=#{@connection_options['database']}", :user=> @connection_options['username'], :password=> @connection_options['password'])
          end

          def load_db_fields(entity_name)
            sys_response = @db[:sysobjects].filter(:type => 'u',:name => entity_name)
            system_id = sys_response.first[:id]

            metadata_fields = []

            columns_response = @db[:syscolumns].filter(:id => system_id)
            columns_response.each do |column|
              case column[:type]

                # Integer
                when 63,48,52,59,50,56
                  type = "integer"
                # Varchar - 9
                # Char - 8
                when 47,99,35,37,39,45
                  type = "string-#{column[:prec]}"
                # Date
                #Timestamp
                when 61,58
                  type = "date-true"
                #Numeric - Decimal
                when 55,63,122,60
                  type = "decimal-#{column[:prec] + column[:scale]}-#{column[:scale]}"
                else
                  $log.info "Unsupported database type #{column[:name]} - using string(255) as default value"
                  type = "string-255"
              end
              field = Metadata::Field.new({
                                              "id" => column[:name],
                                              "name" => column[:name],
                                              "type" => type,
                                              "custom" => {}
                                          })
              metadata_fields << field
            end
            metadata_fields
          end
        end
      end
    end
  end
end
