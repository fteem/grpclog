# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'
RuboCop::RakeTask.new

namespace :test do
  desc 'Generate test protobuf stubs'
  task :generate_proto do |_task, _args|
    system 'bundle exec grpc_tools_ruby_protoc --ruby_out=. --grpc_out=. spec/support/greeter/greeter.proto'
  end
end

task default: %i[spec rubocop]
