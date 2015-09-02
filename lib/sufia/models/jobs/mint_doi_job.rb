require 'doi/datacite'

class MintDoiJob < ActiveFedoraIdBasedJob

  def queue_name
    :doi
  end

  def run
    unless DoiConfig.nil?
      Rails.logger.info "Mint DOI for #{id}"
    
      doi = DataciteDoi.where(object_id: id).current

      client = DOI::Datacite.new(doi)
      client.metadata
      client.mint
      object.doi = doi.doi

      object.save
    end
  end

end
