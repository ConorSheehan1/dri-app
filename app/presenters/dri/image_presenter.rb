module DRI
  class ImagePresenter

    attr_reader :document
    delegate :asset_path, :can?, :cover_image_path, :object_file_path, to: :@view

    def initialize(document, view_context)
      @view = view_context
      @document = document
    end

    def file_type_key
      @file_type_key || ActiveFedora.index_field_mapper.solr_name('file_type', :stored_searchable, type: :string)
    end

    # Called from grid/list/saved object snippet view
    def image_for_search
      files = document.assets
      file_types = document[file_type_key]

      return default_image(file_types) unless can?(:read, document[:id])
      image = nil

      files.each do |file|
        image = search_image(file)
        break if image
      end

      image || default_image(file_types)
    end

    def search_image(file_document, image_name = 'crop16_9_width_200_thumbnail')
      return nil unless file_document[file_type_key].present?

      format = file_document[file_type_key].first
      case format
      when "image"
        search_image_path(file_document.id, image_name)
      when "text"
        search_image_path(file_document.id, "thumbnail_medium")
      else
        nil
      end
    end

    def default_image(file_types)
      return asset_path("no_image.png") if file_types.blank?

      format = file_types.first

      path = "dri/formats/#{format}.png"
      path = "no_image.png" if Rails.application.assets.find_asset(path).nil?

      asset_path(path)
    end

    def cover_image
      path = nil

      solr_doc = document.is_a?(SolrDocument) ? document : SolrDocument.new(document)
      cover_key = ActiveFedora.index_field_mapper.solr_name('cover_image', :stored_searchable, type: :string).to_sym

      path = if solr_doc[cover_key].present? && solr_doc[cover_key].first
               cover_image_path(solr_doc)
             elsif document[ActiveFedora.index_field_mapper.solr_name('root_collection', :stored_searchable, type: :string).to_sym].present?
               collection = solr_doc.root_collection

               if collection[cover_key].present? && collection[cover_key].first
                 cover_image_path(collection)
               end
             end

      path
    end

    private

    def search_image_path(file_doc_id, name)
      return nil unless StorageService.new.surrogate_exists?(document[:id], "#{file_doc_id}_#{name}")

      object_file_path(
        object_id: document[:id],
        id: file_doc_id,
        surrogate: name
      )
    end
  end
end
