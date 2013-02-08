module ApplicationHelper

  # Extract file datastream info from fedora object
  def get_datastreams doc
    @datastreams = ActiveFedora::Base.find(doc.id, {:cast => true}).datastreams
    ""
  end
  
  def get_collections
    collections = DRI::Model::Collection.all
    collections.collect{ |c| [c.title, c.pid] }
  end

  def get_current_collection( object )
    if !object.governing_collection.nil?
      object.governing_collection.pid
    end
  end

  def get_partial_name( object )
    object.class.to_s.downcase.gsub("-"," ").parameterize("_")
  end
end
