# -*- mode: ruby -*-
# vi: set ft=ruby :

source 'https://rubygems.org'

gem 'rails', '3.2.11'
gem 'blacklight', '4.0.0'
gem 'hydra-head', '5.2.0'
gem 'dri_data_models', :git => 'git@dev.forasfeasa.ie:dri_data_models.git'

gem 'sqlite3', :platforms => :ruby

platforms :jruby do
  gem 'jruby-openssl'
  gem 'activerecord-jdbcsqlite3-adapter'
  gem 'jruby-lint'
  gem 'warbler'

  gem 'actionmailer'
  gem 'actionpack'
  gem 'activerecord'
  gem 'activerecord-jdbc-adapter'
  gem 'activeresource'
  gem 'activesupport'
  gem 'jdbc-mysql'
  gem 'rack'
  gem 'rake' 
end

gem 'devise'

gem 'noid', '0.5.5'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  # gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  # gem 'uglifier', '>= 1.0.3'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'jettywrapper'
  gem 'simplecov'

  # guard - autorun of tests during development cycle
  gem 'guard'
  gem 'guard-cucumber'
  gem 'guard-spork'
  gem 'guard-bundler'
  gem 'guard-yard'
  gem 'rb-inotify', :require => false
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false 
end
gem 'jquery-rails'

group :test do
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'launchy'
  gem 'shoulda'
  gem 'factory_girl_rails'
  gem 'syntax'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

gem "unicode", :platforms => [:mri_18, :mri_19]

gem "devise-guests", "~> 0.3"
gem "bootstrap-sass"
gem "yard"
