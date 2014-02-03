module ButtonTranslator

  def button_to_id(button_name)

    case button_name

    when /ingest metadata/
      "ingest_metadata"

    when /upload metadata/
      "replace_metadata"

    when /create record/
      "create_new"

    when /save changes/
      "save_edit"

    when /edit a collection/
      "edit_collection"

    when /save collection changes/
      "edit_collection"

    when /upload a file/
      "upload_file"

    when /replace a file/
      "replace_file"

    when /continue/
      "continue"

    when /update language/
      "commit"

    when /add new collection/
      "new_collection"

    when /create a collection/
      "create_new_collection"

    when /add to collection for id (.+)/
      "collection_toggle_#{$1.parameterize}"

    when /remove from collection (.+)/
      "remove_#{$1}"

    when /set the current collection to (.+)/
      "set_collection_#{$1}"

    when /delete collection with id (.+)/
      "delete_collection_#{$1}"

    when /accept cookie policy/
      "accept_cookies"

    when /search/
      "search"

    when /request access/
      "request_access"

    when /approve membership request/
      "approve_access"

    when /cancel membership request/
      "deny_access"

    when /add an institute/
      "add_institute"

    when /associate an institute/
      "associate_inst"

    else "Unknown"

    end
  end

end
World(ButtonTranslator)
