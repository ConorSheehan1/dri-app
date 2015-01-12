module ButtonTranslator

  def select_box_to_id(select_name)

    case select_name

    when /^ingest methods$/
      "ingestmethod"

    when /^metadata standard$/
      "standard"

    when /^object type$/
      "ingesttype"

    when /^role type$/
      "batch_roles][type]["

    when /^language$/
      "user_locale"

    when /^ingest collection$/
      "ingestcollection"

    when /^add to collection$/
      "collection_id"

    when /^governing collection$/
      "dri_model_governing_collection_id"

    when /^institute$/
      "select_institute"

    when /^licence$/
      "batch_licence"

    else "Unknown"

    end
  end

end
World(ButtonTranslator)
