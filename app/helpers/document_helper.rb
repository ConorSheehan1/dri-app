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

  # For a given collection (sub-collection) object returns a list of the immediate child sub-collections
  def get_collection_children document, limit
    children_array = []
    # Find all immediate children of this collection
    solr_query = "#{Solrizer.solr_name('collection_id', :stored_searchable, type: :string)}:\"#{document['id']}\""
    # Filter to only get those that are collections: fq=is_collection_tesim:true
    q_result = Solr::Query.new(solr_query, limit, :fq => "#{Solrizer.solr_name('is_collection', :stored_searchable, type: :string)}:true")

    while (q_result.has_more?)
      objects_docs = q_result.pop
      objects_docs.each do |obj_doc|
        doc = SolrDocument.new(obj_doc)
        link_text = doc[Solrizer.solr_name('title', :stored_searchable, type: :string)].first
        # FIXME For now, the EAD type is indexed last in the type solr index, review in the future
        type = doc[Solrizer.solr_name('type', :stored_searchable, type: :string)].last

        children_array = children_array.to_a.push [link_text, catalog_path(doc['id']).to_s, type.to_s]
      end
    end

    return children_array
  end

  # Returns a Hash with relationship groups and generated links to related objects for UI Display
  # @param[Solr::Document] document the Solr document of the object to display relations for
  # @return Hash related items grouped by type of relationship
  #
  def get_object_relationships document
    relationships_hash = Hash.new
    object = nil

    if document['active_fedora_model_ssi'] && document['active_fedora_model_ssi'] == 'DRI::Mods'
      object = DRI::Mods.find(document["id"])
    elsif document['active_fedora_model_ssi'] && document['active_fedora_model_ssi'] == 'DRI::QualifiedDublinCore'
      object = DRI::QualifiedDublinCore.find(document["id"])
    end
        
    unless (object.nil?)
      object.get_relationships_names.each do |rel, display_label|
        unless (object.send("#{rel}").nil?)
          if (object.send("#{rel}").respond_to?("push"))
            item_array = []
            object.send("#{rel}").each do |item|
              link_text = item.title.first
              item_array.to_a.push [link_text, catalog_path(item.pid).to_s]
            end
            relationships_hash["#{display_label}"] = item_array unless item_array.empty?
          else
            link_text = object.send("#{rel}").title.first
            relationships_hash["#{display_label}"] = [[link_text, catalog_path(object.send("#{rel}").pid).to_s]]
          end
        end
      end # each
    end 
    
    return relationships_hash
  end # get_object_relationships

  def get_object_external_relationships document
    url_array = []
    
    if document['active_fedora_model_ssi'] && document['active_fedora_model_ssi'] == 'DRI::Mods'
      solr_fields_array = *(DRI::Vocabulary::modsRelationshipTypes.map { |s| s.prepend("ext_related_items_ids_").to_sym})
    elsif document['active_fedora_model_ssi'] && document['active_fedora_model_ssi'] == 'DRI::QualifiedDublinCore'
      solr_fields_array = *(DRI::Vocabulary::qdcRelationshipTypes.map { |s| s.prepend("ext_related_items_ids_").to_sym})
    end

    unless solr_fields_array.nil?
      solr_fields_array.each do |elem|
        if (!document[Solrizer.solr_name(elem, :stored_searchable, type: :string)].nil? && !document[Solrizer.solr_name(elem, :stored_searchable, type: :string)].empty?)
          url_array = url_array.to_a.push(document[Solrizer.solr_name(elem, :stored_searchable, type: :string)].first)
        end
      end
    end
    
    return url_array
  end # get_object_external_relationships

end
