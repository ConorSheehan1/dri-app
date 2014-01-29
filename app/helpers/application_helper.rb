module ApplicationHelper
  require 'storage/s3_interface'

  # Returns the file that should be delivered to the user
  # based on their access rights and the policies and available
  # surrogates of the object
  def get_delivery_file doc
    @asset = nil
    delivery_file = Storage::S3Interface.deliverable_surrogate?(doc)
    @asset = Storage::S3Interface.get_link_for_surrogate(doc.id.sub('dri:',''), delivery_file) unless (delivery_file.blank?)
  end

  def get_files doc
    @files = ActiveFedora::Base.find(doc.id, {:cast => true}).generic_files
    ""
  end

  def get_surrogates doc
    @surrogates = Storage::S3Interface.get_surrogates doc
  end

  def surrogate_url( doc, name )
    Storage::S3Interface.surrogate_url(doc, name)
  end

  def governing_collection( object )
    if !object.governing_collection.nil?
      object.governing_collection.pid
    end
  end

  def governing_collection_solr( doc )
    if doc['is_governed_by_ssim']
      id = doc['is_governed_by_ssim'][0].gsub(/^info:fedora\//, '')
      solr_query = "id:#{id}"
      collection = ActiveFedora::SolrService.query(solr_query, :defType => "edismax", :rows => "1")
    end
    collection[0]
  end

  def get_partial_name( object )
    object.class.to_s.downcase.gsub("-"," ").parameterize("_")
  end

  def collection?( document )
    type?("collection", document)
  end

  def audio?( document )
    type?("sound", document)
  end

  def image?( document )
    type?("image", document)
  end

  def video?( document )
    type?("movingimage", document)
  end

  def document?( document )
    type?("text", document)
  end

  def type?( type, document )
    document["type_ssm"].first.casecmp(type) == 0 ? true : false
  end

  def reader_group_name( document )
    id = document[:is_governed_by_ssim][0].sub('info:fedora/', '')
    name = id.sub(':','_')
    return name
  end

  def count_published_items_in_collection collection_id
    solr_query = "status_ssim:published AND (is_governed_by_ssim:\"info:fedora/" + collection_id +
                 "\" OR is_member_of_collection_ssim:\"info:fedora/" + collection_id + "\" )"
    ActiveFedora::SolrService.count(solr_query, :defType => "edismax")
  end

  def count_items_in_collection_by_type( collection_id, type, status )
    solr_query = "status_ssim:" + status + " AND (is_governed_by_ssim:\"info:fedora/" + collection_id +
                 "\" OR is_member_of_collection_ssim:\"info:fedora/" + collection_id + "\" ) AND " +
                 "object_type_sim:"+ type
    ActiveFedora::SolrService.count(solr_query, :defType => "edismax")
  end

  def get_object_type_counts( document )
    id = document.key?(:is_governed_by_ssim) ? document[:is_governed_by_ssim][0].sub('info:fedora/', '') : document.id

    @type_counts = {}
    Settings.data.types.each do |type|
      @type_counts[type] = { :published => count_items_in_collection_by_type( id, type, "published" ) }

      if signed_in? && (can? :edit, id)
        @type_counts[type][:draft] = count_items_in_collection_by_type( id, type, "draft" )
      end

    end
  end

  def get_institutes( document )
    @institutes = InstituteHelpers.get_institutes_from_solr_doc(@document)
  end

end

