# encoding: utf-8

require 'gooddata_connectors_base/downloaders/base_downloader'

# require_relative 'backends/backends'
# require_relative 'extensions/extensions'

module GoodData
  module Connectors
    module DownloaderSql
      class Sql < Base::BaseDownloader


        def initialize(metadata, options = {})

          @type = 'sql'
          super(metadata, options)
        end

        class << self
          def create_backend(downloader, class_type, options)
            class_name = "#{GoodData::Connectors::DownloaderCsv::Backend}::#{class_type.camelize}"
            klass = Object.class_from_string(class_name)
            klass.new(downloader, options)
          end
        end

        # TODO: Implement
        def connect
          puts 'Connecting to storage with input CSVs'
          # database_type = @metadata.get_configuration_by_type_and_key(@type, 'type')
          database_type = "mssql"
          availible_types = Dir[File.dirname(__FILE__) + "/erb/*"].map{|dir| dir.split("/").last}
          raise Exception,"The given database type #{database_type} is not supported. Supported types #{availible_types.join(",")}" if !availible_types.include?(database_type)
          Base::Template.populate(File.dirname(__FILE__) + "/erb/#{database_type}")

          fail "kokos"

          # @backend_opts = @metadata.get_configuration_by_type_and_key(@type, 'options')
          # @backend = Csv.create_backend(self, source_type, @backend_opts)
          # @backend.connect
          #
          #
          # #We can use connector ID as batch identification
          # batch_id = @metadata.get_configuration_by_type_and_key('global', 'ID')
          # #Lets create batch
          # @batch = Metadata::Batch.new(batch_id)
          # #load_data_structure_info
        end



        # TODO: Implement
        def load_metadata(entity_name)
        end

        # TODO: Implement
        def download_entity_data(entity_name)

        end

        # TODO: Implement
        def define_default_entities
          []
        end




        private



      end
    end
  end
end
