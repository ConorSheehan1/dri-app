module DocumentHelper

  def get_document_type document

    case document[Solrizer.solr_name('file_type_display', :stored_searchable, type: :string).to_sym].first.to_s.downcase
      when "image"
        return t("dri.data.types.Image")
      when "audio"
        return t("dri.data.types.Sound")
      when "video"
        return t("dri.data.types.MovingImage")
      when "text"
        return t("dri.data.types.Text")
      when "mixed_types"
        return t("dri.data.types.MixedType")
      else
        return t("dri.data.types.Unknown")
    end

  end

  def get_collection_media_type_params document, collectionId, mediaType
    if document[Solrizer.solr_name('collection_id', :stored_searchable, type: :string)] == nil
      searchFacets = { Solrizer.solr_name('file_type_display', :facetable, type: :string).to_sym => [mediaType], Solrizer.solr_name('root_collection_id', :facetable, type: :string).to_sym => [collectionId] }
    else
      searchFacets = { Solrizer.solr_name('file_type_display', :facetable, type: :string).to_sym => [mediaType], Solrizer.solr_name('ancestor_id', :facetable, type: :string).to_sym => [collectionId] }
    end
    searchParams = { :mode => "objects", :search_field => "all_fields", :utf8 => "✓", :f => searchFacets }
    return searchParams
  end

  def truncate_description description, count
    if (description.length > count)
      return description.first(count)
    else
      return description
    end
  end

  # Check, based on the document type (Fedora active_fedora_model), whether edit functions are available
  def edit_functionality_available? document
    (document['active_fedora_model_ssi'] && document['active_fedora_model_ssi'] == 'DRI::EncodedArchivalDescription') ? false : true
  end

end
