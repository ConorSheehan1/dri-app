module PathTranslator

  def path_to(page_name)

    case page_name

    when /ingest an object/
      new_audio_path

    when /new Digital Object page/
      new_audio_path

    when /show Digital Object page for id (.+)/
      catalog_path($1)

    when /edit Digital Object page for id (.+)/
      edit_audio_path($1)

    when /the home page/
      '/'

    when /sign in/
     new_user_session_path

    when /User Signin page/
      '/users/sign_in'

    when /User Sign up page/
      '/users/sign_up'

    else "Unknown"

    end
  end

end

World(PathTranslator)
