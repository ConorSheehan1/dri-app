# Load the rails application
require File.expand_path('../application', __FILE__)

ENV_JAVA["http.proxyHost"] = nil
ENV_JAVA["https.proxyHost"] = nil

# Initialize the rails application
NuigRnag::Application.initialize!
