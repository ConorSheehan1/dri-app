module DRI
  class MyCollectionsPresenter < ObjectPresenter

    delegate :url_for, :object_file_url, :current_user, :can?, to: :@view

    def initialize(document, view_context)
      super

      @surrogates = {}
      @status = {}
      surrogate_or_status_info
    end

    def children
      @children ||= document.children(100).select { |child| child.published? || (current_user.is_admin? || can?(:edit, document)) }
    end

    def depositing_organisations
      @depositing_organisations ||= Institute.where(depositing: true).pluck(:name)
    end

    def displayfiles
      @displayfiles ||= files.reject { |file| file.preservation_only? }
    end

    def files
      @files ||= document.assets(true).sort_by! { |f| f[ActiveFedora.index_field_mapper.solr_name('label')] }
    end

    def relationships
      @relationships ||= object_relationships
    end

    def surrogates(file_id)
      @surrogates[file_id]
    end

    def status(file_id)
      @status[file_id]
    end

    def unassigned_organisations
      @unassigned_organisations ||= all_organisations - current_collection_organisations - [depositing_organisation.try(:name)]
    end

    def assigned_organisations
      @removal_institutes = current_collection_organisations - [depositing_organisation.try(:name)]
    end

    private

      def surrogate_or_status_info
        files.each do |file|
          # get the surrogates for this file if they exist
          surrogates = document.surrogates(file.id)
          if surrogates.present?
            @surrogates[file.id] = surrogates_with_url(file.id, surrogates)
          else
            @status[file.id] = file_status(file.id)
          end
        end
      end

      def file_status(file_id)
        ingest_status = IngestStatus.where(asset_id: file_id)
        if ingest_status.present?
          status = ingest_status.first
          { status: status.status }
        end
      end

      def object_relationships
        relationships = document.object_relationships
        filtered_relationships = {}

        relationships.each do |key, array|
          filtered_array = array.select { |item| item[1].published? || (current_user.is_admin? || can?(:edit, item[1])) }
          unless filtered_array.empty?
            filtered_relationships[key] = Kaminari.paginate_array(filtered_array).page(params[key.downcase.gsub(/\s/, '_') << '_page']).per(4)
          end
        end

        filtered_relationships
      end

      def surrogates_with_url(file_id, surrogates)
        surrogates.each do |key, _path|
          surrogates[key] = url_for(object_file_url(
                              object_id: document.id, id: file_id, surrogate: key
                        ))
        end
      end

      def all_organisations
        @all_organisations ||= Institute.all.pluck(:name)
      end

      def current_collection_organisations
        @current_collection_organisations ||= organisations.map(&:name)
      end
  end
end
