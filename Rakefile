# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "simple_units"
  gem.homepage = "http://github.com/foxnewsnetwork/simple_units"
  gem.license = "MIT"
  gem.summary = %Q{Simple units implementation. Similar to ruby-units except with a lot less features and zero collisons with rails.}
  gem.description = %Q{Sure, ruby is dynamic and that is one of its greatest strength. Object polymorphisms, duck typing, and the like is great in ruby, there is a time and place for everything. Sometimes, it just makes more sense to be strongly typed.}
  gem.email = "foxnewsnetwork@gmail.com"
  gem.authors = ["Thomas Chen"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "simple_units #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
