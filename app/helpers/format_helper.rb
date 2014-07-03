module FormatHelper

  def collection?( document )
    has_type?("collection", document)
  end

  def audio?( document )
    has_type?("audio", document)
  end

  def image?( document )
    has_type?("image", document)
  end

  def video?( document )
    has_type?("video", document)
  end

  def document?( document )
    has_type?("text", document)
  end

  def has_type?( type, document )
    type.casecmp(format?( document )) == 0 ? true : false
  end

  def format? ( document )
    unless document[Solrizer.solr_name('file_type', :stored_searchable, type: :string)].blank?
      format = document[Solrizer.solr_name('file_type', :stored_searchable, type: :string)].first
    else
      format = "unknown"
    end

    format
  end

end
