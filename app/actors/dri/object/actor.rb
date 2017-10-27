module DRI
  module Object
    class Actor
      attr_reader :object, :user

      def initialize(object, user)
        @object = object
        @user = user
      end

      def find_duplicates
        if @object.governing_collection.present?
          ActiveFedora::SolrService.query(
            solr_query,
            defType: 'edismax',
            rows: '10',
            fl: 'id'
          ).delete_if { |obj| obj['id'] == @object.id }
        end
      end

      def solr_query
        md5_field = ActiveFedora.index_field_mapper.solr_name(
          'metadata_md5',
          :stored_searchable,
          type: :string
        )
        governed_field = ActiveFedora.index_field_mapper.solr_name(
          'isGovernedBy',
          :stored_searchable,
          type: :symbol
        )
        query = "#{md5_field}:\"#{@object.metadata_md5}\""
        query += " AND #{governed_field}:\"#{@object.governing_collection.id}\""

        query
      end

      def verify
        preservator = Preservation::Preservator.new(@object)
        version = preservator.version_string(@object.object_version)

        storage_object = Moab::StorageObject.new(@object.id, preservator.aip_dir)
        storage_object_version = Moab::StorageObjectVersion.new(storage_object, version_id=version)
        result = storage_object_version.verify_version_storage

        [result.verified, result]
      end

      def version_and_record_committer
        @object.create_version

        version_id = if @object.has_versions?
                       @object.versions.last.uri
                     else
                       @object.uri.to_s
                     end

        VersionCommitter.create(version_id: version_id, obj_id: @object.id, committer_login: @user.to_s)
      end
    end
  end
end
