# -*- mode: ruby -*-
# vi: set ft=ruby :

source 'http://rubygems.org'

gem 'rails','~> 4.2'
# fix rails dependency problem
gem 'sinatra', '1.4.8'

gem 'blacklight', '~> 5.19.0'

gem 'hydra-head', '9.10'

gem 'riiif', '1.2.0'
gem 'iiif-presentation', git: 'https://github.com/IIIF/osullivan.git'
gem 'openseadragon'

gem 'redlock'
gem 'google-api-client', '~> 0.9'
gem 'googleauth', '0.5.1'

gem 'paper_trail', '~> 4'

gem 'dri_data_models', git: 'ssh://git@tracker.dri.ie:2200/drirepo/dri-data-models.git', branch: 'develop'
gem 'user_group', git: 'ssh://git@tracker.dri.ie:2200/drirepo/dri-user-group.git', branch: 'develop'

gem 'dri_batch_ingest', git: 'https://github.com/Digital-Repository-of-Ireland/dri-batch-ingest.git'
gem 'roo', '2.6.0'

gem 'active-fedora', '9.11'
gem 'active_fedora-noid', '1.1.1'

gem 'config'
gem 'sqlite3'
gem 'mysql'
gem 'mysql2'

gem 'omniauth-shibboleth'
gem 'oauth'

gem 'feedjira'

# Storage-related gems
gem 'moab-versioning'
gem 'browse-everything', git: 'https://github.com/stkenny/browse-everything.git', branch: 'feature/per_user'
gem 'avalon_ingest', git: 'https://github.com/stkenny/avalon_ingest'

# File processing gems
gem 'mimemagic'

# Language and translation related gems
gem 'http_accept_language'
gem 'it'
gem 'i18n-tasks', '~> 0.9.15'

# logging
gem 'syslog-logger'

gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-cookie-rails'

# clients
gem 'rest-client'
gem 'sparql-client'

# static pages
gem 'high_voltage', '~> 2.1.0'

# monitoring 
# is it working fork
gem 'is_it_working-cbeer'
gem 'honeybadger', '~> 2.0'
gem 'resque', '1.26'
gem 'resque-status'
gem 'nest'

gem 'sass-rails' , '~> 4.0.4'
#gem 'compass', '0.12.7'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'execjs'

gem 'uglifier', '>= 1.0.3'

group :production do
  gem 'clamav'
end

group :development, :test do
  gem 'guard'
  gem 'rspec-rails', '~> 3.0'
  gem 'poltergeist', '>= 1.11.0'
  gem 'phantomjs', :require => 'phantomjs/poltergeist'
  gem 'simplecov'
  gem 'simplecov-rcov'
  gem 'railroady'
  gem 'show_me_the_cookies'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'guard-livereload', require: false

  gem "zeus", require: false

  gem 'ci_reporter_rspec'

  gem 'solr_wrapper', '~> 0.18'
  gem 'fcrepo_wrapper', '0.6.0'

  gem 'fakes3', git: 'ssh://git@tracker.dri.ie:2200/drirepo/fake-s3.git', branch: 'issue22'
end

group :test do
  gem 'cucumber', '2.3.3'
  gem 'cucumber-rails', '1.4.3', require: false
  gem 'database_cleaner'
  gem 'launchy'
  gem 'shoulda'
  gem 'factory_bot_rails'
  gem 'ffaker'
  gem 'syntax'
  gem 'cucumber-api-steps'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
gem 'unicorn'

# To use debugger
# gem 'debugger'

gem 'unicode', platforms: [:mri_18, :mri_19]
gem 'font-awesome-rails', '4.5.0.1'
gem 'jwt', '1.5.2'
gem 'bootstrap-sass', '3.3.5'
gem 'bootstrap-glyphicons'
gem 'yard'

group :translations do
  gem 'i18n_sync'
end

# analytics
gem 'google-analytics-rails', '1.1.0'
gem 'gabba'
gem 'legato'
gem 'google-oauth2-installed'

gem 'rvm'

# UI widgets
gem 'colorbox-rails'
gem 'bootstrap-switch-rails'
gem 'timelineJS3-rails', git: 'https://github.com/stkenny/timelineJS3-rails.git'
gem 'openlayers-rails'
gem 'social-share-button'
gem 'jquery-xmleditor-rails', git: 'https://github.com/stkenny/jquery-xmleditor-rails.git', branch: 'form_upload'

gem 'blacklight-maps'
gem 'leaflet-rails', '1.0.0'
gem 'rails-assets-leaflet', '1.1.0', source: 'https://rails-assets.org'
gem 'rails-assets-leaflet.markercluster', '1.3.0', source: 'https://rails-assets.org'

gem 'jquery-datatables', git: 'https://github.com/stkenny/jquery-datatables.git'
gem "jquery-slick-rails"
gem 'remotipart'

