# encoding: utf-8

require 'gooddata_connectors_base/downloaders/base_downloader'

require_relative 'backends/backends'
require_relative 'extensions/extensions'

module GoodData
  module Connectors
    module DownloaderSql
      class Sql < Base::BaseDownloader


        def initialize(metadata, options = {})
          @type = 'sql'
          super(metadata, options)
        end

        class << self
          def create_backend(class_type, options)
            class_name = "#{GoodData::Connectors::DownloaderSql::Backend}::#{class_type}"
            klass = Object.class_from_string(class_name)
            backend = klass.new(options)
            backend.create_connection
            backend
          end
        end


        def connect
          puts 'Connecting to storage with input CSVs'
          # database_type = @metadata.get_configuration_by_type_and_key(@type, 'type')
          database_type = @metadata.get_configuration_by_type_and_key(@type, 'type')
          options = @metadata.get_configuration_by_type_and_key(@type, 'options')
          @backend = Sql.create_backend(database_type,options["connection"])
        end


        def load_metadata(entity_name)
          metadata_entity = @metadata.get_entity(entity_name)
          temporary_fields = @backend.load_db_fields(entity_name)
          diff = metadata_entity.diff_fields(temporary_fields)
          # Merging entity and disabling add of new fields
          if (@metadata.load_fields_from_source?(metadata_entity.id))
            diff["only_in_target"].each do |target_field|
              # The field is not in current entity, we need to create it
              $log.info "Adding new field #{target_field.name} to entity #{metadata_entity.id}"
              target_field.order = metadata_entity.get_new_order_id
              metadata_entity.add_field(target_field)
              metadata_entity.make_dirty()
            end
          end

          diff["only_in_source"].each do |source_field|
            if (!source_field.disabled?)
              $log.info "Disabling field #{source_field.name} in entity #{metadata_entity.id}"
              source_field.disable("From synchronization with source system")
              metadata_entity.make_dirty()
            end
          end

          diff["changed"].each do |change|
            source_field = change["source_field"]
            $log.info "The field #{source_field.name} in entity #{metadata_entity.id} has changed"
            #source_field.name = change["target_field"].name if change.include?("name")
            raise Exception,"The type in data structure file for field #{source_field.name} for entity #{metadata_entity.id} has changed. This is not supported in current version of SQL connector" if change.include?("type")
            metadata_entity.make_dirty()
          end

          if !metadata_entity.custom.include?("download_by") or metadata_entity.custom["download_by"] != @type
            metadata_entity.custom["download_by"] = @type
            metadata_entity.make_dirty()
          end

          if !metadata_entity.custom.include?("enclosed_by") or metadata_entity.custom["enclosed_by"] != '"'
            metadata_entity.custom["enclosed_by"] = '"'
            metadata_entity.make_dirty()
          end
          metadata.save_entity(metadata_entity)
        end

        # TODO: Implement
        def download_entity_data(entity_name)
          metadata_entity = @metadata.get_entity(entity_name)
          file = @backend.download_data(entity_name,metadata_entity.get_enabled_fields)
          metadata_entity.store_runtime_param("source_filename",file)
          response = @metadata.save_data(metadata_entity)
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
