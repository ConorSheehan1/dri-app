module FacetsHelper
  include Blacklight::FacetsHelperBehavior

  # Used by CatalogController's language facet_field, show_field and index_field
  # to parse a language code into the full name when needed
  # NOTE: Requires Blacklight 4.2.0 for facet_field to work
  def label_language args
    results = nil

    if args.is_a?(Hash)
      results = Array.new
      value_list = args[:document][args[:field]]

      value_list.each do |value|
        results.push(transform_language value)
      end
    else
      results = transform_language args
    end

    return results
  end

  # Fetches the correct internationalization translation for a given language code
  def transform_language value
    if value == nil
      return 'nil'
    end

    standard_lang = DRI::Metadata::Descriptors.standardise_language_code value

    if standard_lang != nil
      t('dri.vocabulary.iso_639_2.'+standard_lang)
    else
      value
    end
  end

  def label_permission args
    results = nil

    if args.is_a?(Hash)
      results = Array.new
      value_list = args[:document][args[:field]]

      value_list.each do |value|
        results.push(transform_permission value)
      end
    else
      results = transform_permission args
    end

    return results
  end

  # Used as helper_method in CatalogController's add_facet_field, doesn't seem to get called.
  def transform_permission value
    case value
    when "0"
      return t('dri.views.objects.access_controls.public')
    when "1"
      return t('dri.views.objects.access_controls.private')
    when "-1"
      return t('dri.views.objects.access_controls.inherited')
    else
      return "unknown?"
    end
  end

  # Overwriting this helper so that we can translate facet values
  # Delete this when Blacklight 4.2 is installed
  def render_facet_value(facet_solr_field, item, options ={})
    label = item.label
    facet_config = facet_configuration_for_field(facet_solr_field)
    if facet_config.label == "Language"
    	label = label_language label
    elsif facet_config.label == "Metadata Search Access" || facet_config.label == "Master File Access"
      label = label_permission label
    end
    # (link_to_unless(options[:suppress_link], label, add_facet_params_and_redirect(facet_solr_field, item), :class=>"facet_select") + " " + render_facet_count(item.hits)).html_safe
    (link_to_unless(options[:suppress_link], label.html_safe + " (#{render_facet_count(item.hits)})".html_safe, add_facet_params_and_redirect(facet_solr_field, item)))
  end


  # Renders a count value for facet limits. Can be over-ridden locally
  # to change style. And can be called by plugins to get consistent display
  def render_facet_count(num)
    content_tag("b", t('blacklight.search.facets.count', :number => num))
  end


  # Standard display of a SELECTED facet value, no link, special span
  # with class, and 'remove' button.
  def render_selected_facet_value(facet_solr_field, item)
    #Updated class for Bootstrap Blacklight.
    
      link_to(render_facet_value(facet_solr_field, item, :suppress_link => true), remove_facet_params(facet_solr_field, item, params), :class=>"selected")
  end

  # Overwriting this helper so that values containing colons are automatically enclosed in double-quoted strings,
  # otherwise SOLR will report an error.
  def facet_value_for_facet_item item
    value = ""

    if item.respond_to? :value
      value = item.value
    else
      value = item
    end

    if (value.include? ":")
      value = '"'+value+'"'
    end

    value
  end

end
