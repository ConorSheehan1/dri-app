class ReviewJob
  include Resque::Plugins::Status

  def queue
    :review
  end

  def name
    'ReviewJob'
  end

  def perform
    collection_id = options['collection_id']
    set_status(collection_id: collection_id)

    # get objects within this collection, not including sub-collections
    q_str = "#{ActiveFedora.index_field_mapper.solr_name('collection_id', :facetable, type: :string)}:\"#{collection_id}\""
    q_str += " AND #{ActiveFedora.index_field_mapper.solr_name('status', :stored_searchable, type: :symbol)}:draft"
    f_query = "#{ActiveFedora.index_field_mapper.solr_name('is_collection', :stored_searchable, type: :string)}:false"

    completed, failed = set_as_reviewed(collection_id, q_str, f_query)
    collection = DRI::Identifier.retrieve_object(collection_id)

    # Need to set sub-collection to reviewed
    if subcollection?(collection)
      collection.status = 'reviewed'
      version = collection.object_version || '1'
      collection.object_version = (version.to_i + 1).to_s
      failed += 1 unless collection.save

      # Do the preservation actions
      preservation = Preservation::Preservator.new(collection)
      preservation.preserve(false, false, ['properties'])
    end

    completed(completed: completed, failed: failed)
  end

  def set_as_reviewed(collection_id, q_str, f_query)
    total_objects = ActiveFedora::SolrService.count(q_str, { fq: f_query })

    query = Solr::Query.new(q_str, 100, fq: f_query)

    completed = 0
    failed = 0

    while query.has_more?
      collection_objects = query.pop

      collection_objects.each do |object|
        o = DRI::Identifier.retrieve_object(object['id'])
        if o && o.status == 'draft'
          o.status = 'reviewed'
          version = o.object_version || '1'
          o.object_version = (version.to_i + 1).to_s
          o.save ? (completed += 1) : (failed += 1)

          # Do the preservation actions
          preservation = Preservation::Preservator.new(o)
          preservation.preserve(false, false, ['properties'])
        end
      end

      unless total_objects.zero?
        at(completed, total_objects,
           "Reviewing #{collection_id}: #{completed} of #{total_objects} marked as reviewed")
      end
    end

    return completed, failed
  end

  def subcollection?(object)
    object.collection? && !object.root_collection?
  end
end
