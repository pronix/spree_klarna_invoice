require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/packagetask'
require 'rubygems/package_task'
require 'rspec/core/rake_task'
require 'spree/testing_support/common_rake'

RSpec::Core::RakeTask.new

task default: :spec

spec = eval(File.read('spree_klarna_invoice.gemspec'))

Gem::PackageTask.new(spec) do |p|
  p.gem_spec = spec
end

desc 'Generates a dummy app for testing'
task :test_app do
  ENV['LIB_NAME'] = 'spree_klarna_invoice'
  Rake::Task['common:test_app'].invoke
end

namespace :test_app do
  desc 'Rebuild test database'
  task :rebuild do
    rebuild = 'cd spec/dummy && export RAILS_ENV=test '
    rebuild << ' && rake spree:install:migrations'
    rebuild << ' && rake spree_auth:install:migrations'
    rebuild << ' && rake spree_klarna_invoice:install:migrations'
    rebuild << ' && rake db:drop && rake db:create && rake db:migrate'
    system rebuild
  end
end
