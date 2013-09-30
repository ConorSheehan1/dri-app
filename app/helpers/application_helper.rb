module ApplicationHelper
  require 'storage/s3_interface'

  # Extract file datastream info from fedora object
  def get_datastreams doc
    @datastreams = ActiveFedora::Base.find(doc.id, {:cast => true}).datastreams
    ""
  end

  def get_files doc
    @files = ActiveFedora::Base.find(doc.id, {:cast => true}).generic_files
    ""
  end

  def get_surrogates doc
    @surrogates = Storage::S3Interface.get_surrogates doc
  end
  
  def get_collections
    results = Array.new
    solr_query = "+object_type_sim:Collection +depositor_sim:*"
    result_docs = ActiveFedora::SolrService.query(solr_query, :defType => "edismax", :rows => "500", :fl => "id,title_tesim")
    result_docs.each do | doc |
      results.push([doc["title_tesim"][0], doc['id']])
    end

    return results
  end

  def get_governing_collection( object )
    if !object.governing_collection.nil?
      object.governing_collection.pid
    end
  end

  def get_current_collection
    if session[:current_collection]
      return Batch.find(session[:current_collection])
    else
      return nil
    end
  end

  def existing_collection_for( object_id )
    get_current_collection.items.to_a.find {|b| b.id == object_id}
  end

  def get_partial_name( object )
    object.class.to_s.downcase.gsub("-"," ").parameterize("_")
  end

end
