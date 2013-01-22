# Load the rails application
require File.expand_path('../application', __FILE__)

#ENV_JAVA["http.proxyHost"] = nil
#ENV_JAVA["https.proxyHost"] = nil
ENV_JAVA["http.nonProxyHosts"] = "localhost"

# Initialize the rails application
NuigRnag::Application.initialize!
