#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

DriApp::Application.load_tasks

APP_ROOT= File.dirname(__FILE__)

require 'rspec/core'
require 'rspec/core/rake_task'
require 'bundler'
require 'active_fedora/rake_support'

require 'ci/reporter/rake/rspec'

begin
  require 'rdoc/task'
rescue LoadError
  require 'rdoc/rdoc'
  require 'rake/rdoctask'
  RDoc::Task = Rake::RDocTask
end

# Load rake tasks for development and testing
unless Rails.env.production?
  Dir.glob(File.expand_path('../tasks/*.rake', __FILE__)).each do |f|
    load(f)
  end
end

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'dri-app'
  rdoc.options << '--line-numbers'
  rdoc.main = "README.rdoc"
  rdoc.rdoc_files.include('*.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('app/**/*.rb')
end

RSpec::Core::RakeTask.new(:rspec => ['ci:setup:rspec']) do |rspec|
  rspec.pattern = FileList['spec/*_spec.rb']
end

Cucumber::Rake::Task.new(:first_try) do |t|
  t.cucumber_opts = "--profile first_try"
end

Cucumber::Rake::Task.new(:second_try) do |t|
  t.cucumber_opts = "--profile second_try"
end

desc "Run Continuous Integration"
task :ci => ['ci_clean'] do
  ENV['environment'] = "test"
  Rake::Task['db:migrate'].invoke
  
  with_test_server do
    begin
      Rake::Task['first_try'].invoke
    rescue Exception => e
    end

    Rake::Task['second_try'].invoke
  end
end

desc "Run Continuous Integration-spec"
task :ci_spec => ['ci_clean'] do
  ENV['environment'] = "test"
  Rake::Task['db:migrate'].invoke

  with_test_server do 
    Rake::Task['spec'].invoke
    Rake::Task["api:docs:generate"].invoke
  end
end

desc "Clean CI environment"
task :ci_clean do
  rm_rf 'features/reports'
end

namespace :rvm do
  desc 'Trust rvmrc file'
  task :trust_rvmrc do
    system(". ~/.rvm/scripts/rvm && rvm rvmrc trust .rvmrc && rvm rvmrc load")
  end

end

task restart_workers: :environment do
  pids = Array.new
  Resque.workers.each do |worker|
    pids << worker.to_s.split(/:/).second
  end
  if pids.size > 0
    system("kill -QUIT #{pids.join(' ')}")
  end
end

namespace :solr do
  namespace :dri do
    desc 'Reindex Solr as background task in the correct order (GenericFiles followed by Batch objects)'
    task reindex: :environment do
      Sufia.queue.push(ReindexSolrJob.new)
    end
  end
end

namespace :fakes3 do
  desc 'Start fakes3'
  task start: :environment do
    fakes3_dir = 'tmp/fakes3/'
    FileUtils.mkdir_p(fakes3_dir) unless Dir.exists?(fakes3_dir)
    system("fakes3 -r #{fakes3_dir} -p 8081 -H localhost")
  end
end

desc 'similar to rswag:spec:swaggerize except it does not use --dry-run so output is included in swagger docs where applicable'
namespace :api do
  namespace :docs do
    desc 'Generate Swagger JSON files from integration specs'
    RSpec::Core::RakeTask.new('generate', :pattern) do |t|
      if ARGV[1] and ARGV[1].start_with?('spec/api/')
        puts '[WARNING] running a subset of the test suite will remove output for tests that do not run. Continue? y/n'
        input = STDIN.gets.chomp
        abort unless input.downcase == 'y'
        t.pattern = ARGV[1] 
      else
        t.pattern = 'spec/api/**/*_spec.rb'
      end

      t.rspec_opts = [ 
        '--format progress',
        '--format Rswag::Specs::SwaggerFormatter',
        '--order defined',
        '--exclude-pattern ""'
      ]
    end
  end
end

# custom seed files to add/remove data for dev/test
# e.g bundle exec rake db:seed:add_organisations
namespace :db do
  namespace :seed do
    Dir[Rails.root.join('db', 'seeds', '*.rb')].each do |filename|
      cmd = File.basename(filename, '.rb')
      tasks = ["add_#{cmd}", "add_#{cmd}!", "remove_#{cmd}", "remove_#{cmd}!"]
      tasks.each do |task_name|
        desc "Seed " + task_name
        task task_name.to_sym => :environment do
          if File.exist?(filename)
            require(filename)
            puts "starting #{task_name} seeds"
            Seeds.send("#{task_name}".to_sym)
            puts "finished #{task_name} seeds"
          end
        end
      end
    end
  end
end
