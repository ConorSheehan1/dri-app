require 'simplecov'
require 'simplecov-rcov'
require 'active_fedora/cleaner'

class SimpleCov::Formatter::MergedFormatter
  def format(result)
    SimpleCov::Formatter::HTMLFormatter.new.format(result)
    SimpleCov::Formatter::RcovFormatter.new.format(result)
  end
end
SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter

SimpleCov.start 'rails'

require 'rubygems'
require 'i18n'
require 'capybara/cucumber'
require 'selenium-webdriver'
require 'cucumber/rspec/doubles'
require 'cucumber/api_steps'
require 'rake'
require 'rspec'
require 'billy/capybara/cucumber'

Capybara.register_driver :selenium do |app|
        options = Selenium::WebDriver::Chrome::Options.new(
                args: [
                  "headless", 
                  "no-sandbox",
                  "proxy-server=#{Billy.proxy.host}:#{Billy.proxy.port}"
                ]
        )
        Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end
Capybara.javascript_driver = :selenium
Capybara.ignore_hidden_elements = false
Capybara.server = :webrick

# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a
# newer version of cucumber-rails. Consider adding your own code to a new file
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

require 'cucumber/rails'
require 'factory_bot'

# Capybara defaults to XPath selectors rather than Webrat's default of CSS3. In
# order to ease the transition to Capybara we set the default here. If you'd
# prefer to use XPath just remove this line and adjust any selectors in your
# steps to use the XPath syntax.
Capybara.default_selector = :css

# By default, any exception happening in your Rails application will bubble up
# to Cucumber so that your scenario will fail. This is a different from how
# your application behaves in the production environment, where an error page will
# be rendered instead.
#
# Sometimes we want to override this default behaviour and allow Rails to rescue
# exceptions and display an error page (just like when the app is running in production).
# Typical scenarios where you want to do this is when you test your error pages.
# There are two ways to allow Rails to rescue exceptions:
#
# 1) Tag your scenario (or feature) with @allow-rescue
#
# 2) Set the value below to true. Beware that doing this globally is not
# recommended as it will mask a lot of errors for you!
#
ActionController::Base.allow_rescue = false

# Remove/comment out the lines below if your app doesn't have a database.
# For some databases (like MongoDB and CouchDB) you may need to use :truncation instead.
#begin
#  DatabaseCleaner.strategy = :truncation
#rescue NameError
#  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
#end

# You may also want to configure DatabaseCleaner to use different strategies for certain features and scenarios.
# See the DatabaseCleaner documentation for details. Example:
#
#   Before('@no-txn,@selenium,@culerity,@celerity,@javascript') do
#     # { :except => [:widgets] } may not do what you expect here
#     # as tCucumber::Rails::Database.javascript_strategy overrides
#     # this setting.
#     DatabaseCleaner.strategy = :truncation
#   end
#
#   Before('~@no-txn', '~@selenium', '~@culerity', '~@celerity', '~@javascript') do
#     DatabaseCleaner.strategy = :transaction
#   end
#

# Possible values are :truncation and :transaction
# The :transaction strategy is faster, but might give you threading problems.
# See https://github.com/cucumber/cucumber-rails/blob/master/features/choose_javascript_database_strategy.feature
Cucumber::Rails::Database.javascript_strategy = :truncation

#
# DRI-TCD - should be moved to a more sensible location to avoid being over-ridden
#
class Module
  def recursive_const_get(name)
    name.to_s.split("::").inject(self) do |b, c|
      b.const_get(c)
    end
  end
end

Before do
  allow(DRI.queue).to receive(:push) 
  allow_any_instance_of(DRI::Versionable).to receive(:version_and_record_committer)
  allow(Feedjira::Feed).to receive(:fetch_and_parse)

  clean_repo

  @tmp_assets_dir = Dir.mktmpdir
  Settings.dri.files = @tmp_assets_dir
end

Before('@stub_requests') do
  # stub questioning authority autocomplete requests
  qa_base = /http:\/\/(localhost|127.0.0.1):\d+\/qa\/search/
  loc_base = /#{qa_base}\/loc\/subjects/
  logainm_base = /#{qa_base}\/logainm\/subjects/
  nuts3_base = /#{qa_base}\/nuts3\/subjects/
  oclc_base = /#{qa_base}\/assign_fast\/all/
  unesco_base = /#{qa_base}\/nuts3\/subjects/

  [loc_base, logainm_base, nuts3_base, oclc_base, unesco_base,].each do |regex_base|
    proxy.stub(/#{regex_base}.*/).and_return(json: [])
    # pass param through (i.e. whatever the user types, return that as an autocomplete result)
    proxy.stub(/#{regex_base}\?q=(.*)/i).and_return(Proc.new { |params, headers, body, url, method|
      # labels at real endpoints are usually capitalized
      label = params['q'].first.split(/\s+/).map {|v| v.capitalize }.join(' ')
      uri = "http://example.com/#{params['q'].first.gsub(/\s+/, '_')}"
      {
        :code => 200,
        json: [ { label: label, id: uri } ]
      }
    })
  end
end

After do
  Capybara.use_default_driver
end

def last_json
  page.source
end
