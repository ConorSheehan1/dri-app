module PathTranslator

  def path_to(page_name)

    case page_name

    when /ingest an object/
      new_ingest_path

    when /new Digital Object page/
      new_ingest_path

    when /show Digital Object page for id (.+)/
      catalog_path($1)

    when /edit Digital Object page for id (.+)/
      edit_object_path($1)

    when /show page for the collection "(.+)"/
      collection_path($1)

    when /the home page/
      root_path

    when /sign in/
     user_group.new_user_session_path

    when /sign out/
      user_group.destroy_user_session_path

    when /User Signin page/
      user_group.new_user_session_path

    when /User Sign up page/
      user_group.new_user_path

    when /new Collection page/
      new_collection_path

    when /view collection page/
      collections_path

    when /my collections page/
      collections_path

    when /show page for the collection/
      collection_path(@collection.id)

    else
      raise('You specified an invalid path')

    end
  end

end

World(PathTranslator)
