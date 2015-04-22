# -*- encoding : utf-8 -*-
# Generated Solr Document model
#
class SolrDocument 
 
  include Blacklight::Solr::Document
  include UserGroup::PermissionsSolrDocOverride

  # self.unique_key = 'id'
  
  # The following shows how to setup this blacklight document to display marc documents
  #extension_parameters[:marc_source_field] = :marc_display
  #extension_parameters[:marc_format_type] = :marcxml
  #use_extension( Blacklight::Solr::Document::Marc) do |document|
  #  document.key?( :marc_display  )
  #end
  
  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension( Blacklight::Solr::Document::Email )
  
  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension( Blacklight::Solr::Document::Sms )

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension( Blacklight::Solr::Document::DublinCore)    
  field_semantics.merge!(    
                         :title => "title_display",
                         :author => "author_display",
                         :language => "language_facet",
                         :format => "format"
                         )

  def collection_id
    id = nil
    if self[ActiveFedora::SolrQueryBuilder.solr_name('isGovernedBy', :stored_searchable, type: :symbol)]
      id = self[ActiveFedora::SolrQueryBuilder.solr_name('isGovernedBy', :stored_searchable, type: :symbol)][0]
    end

    id
  end  

  def has_geocode?
    box_key = ActiveFedora::SolrQueryBuilder.solr_name('geocode_box', :stored_searchable, type: :string).to_sym
    point_key = ActiveFedora::SolrQueryBuilder.solr_name('geocode_point', :stored_searchable, type: :string).to_sym

    if self[point_key].present? || self[box_key].present?
      true
    else
      false
    end
  end

end
