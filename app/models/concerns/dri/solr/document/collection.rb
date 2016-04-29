module DRI::Solr::Document::Collection

  def children(limit)
    children_array = []
    # Find immediate children of this collection
    solr_query = "#{Solrizer.solr_name('collection_id', :stored_searchable, type: :string)}:\"#{self.id}\""
    f_query = "#{Solrizer.solr_name('is_collection', :stored_searchable, type: :string)}:true"

    # Filter to only get those that are collections:
    # fq=is_collection_tesim:true
    q_result = Solr::Query.new(solr_query, limit, fq: f_query)
    q_result.each_solr_document do |doc|
      children_array << doc
    end

    children_array
  end

  def draft_objects
    status_count('draft')
  end

  def draft_subcollections
    status_count('draft', true)
  end

  def published_objects
    status_count('published')
  end

  def reviewed_objects
    status_count('reviewed')
  end

  def reviewed_subcollections
    status_count('reviewed', true)
  end

 def duplicate_total
    response = duplicate_query

    duplicates = response['facet_counts']['facet_fields']["#{metadata_field}"]
   
    total = 0
    duplicates.each_slice(2) { |duplicate| total += duplicate[1].to_i }
   
    total
  end

  def duplicates
    response = duplicate_query
    
    ids = []
    duplicates = response['facet_counts']['facet_pivot']["#{metadata_field},id"].select { |f| f['count'] > 1 }
    duplicates.each do |dup|
      pivot = dup["pivot"]
      pivot.each { |p| ids << p['value'] }
    end

    query = ActiveFedora::SolrQueryBuilder.construct_query_for_ids(ids)
    response = ActiveFedora::SolrService.get(query)
    
    docs = response['response']['docs']

    duplicates = []
    docs.each { |d| duplicates << SolrDocument.new(d) }
      
    return Blacklight::Solr::Response.new(response['response'], response['responseHeader']), duplicates
  end

  private

  def metadata_field
    ActiveFedora.index_field_mapper.solr_name('metadata_md5', :stored_searchable, type: :string)
  end

  def status_count(status, subcoll=false)
    query = "#{ActiveFedora.index_field_mapper.solr_name('ancestor_id', :facetable, type: :string)}:#{self.id} 
      AND #{ActiveFedora.index_field_mapper.solr_name('status', :stored_searchable, type: :symbol)}:#{status}
      AND #{ActiveFedora.index_field_mapper.solr_name('is_collection', :searchable, type: :symbol)}:#{subcoll}"

    ActiveFedora::SolrService.count(query)
  end
  
  def duplicate_query
    query_params = { fq: ["+#{ActiveFedora.index_field_mapper.solr_name('ancestor_id', :facetable, type: :string)}:#{self.id}", 
      "+has_model_ssim:\"DRI::Batch\"", "+is_collection_sim:false"], 
      "facet.pivot" => "#{metadata_field},id", 
      facet: true, 
      "facet.mincount" => 2, 
      "facet.field" => "#{metadata_field}" }
    
    ActiveFedora::SolrService.get('*:*', query_params)
  end

end
