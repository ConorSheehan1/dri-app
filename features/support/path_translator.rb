module PathTranslator

  def path_to(page_name)

    case page_name

    when /ingest an object/
      new_object_path

    when /new Digital Object page/
      new_object_path

    when /show Digital Object page for id (.+)/
      catalog_path($1)

    when /edit Digital Object page for id (.+)/
      edit_object_path($1)

    when /the home page/
      '/'

    when /sign in/
     new_user_session_path

    when /User Signin page/
      new_user_session_path

    when /User Sign up page/
      new_user_registration_path

    else "Unknown"

    end
  end

end

World(PathTranslator)
