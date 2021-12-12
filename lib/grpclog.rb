# frozen_string_literal: true

require 'grpc'
require 'json'

require_relative 'grpclog/version'
require_relative 'grpclog/server_interceptor'
require_relative 'grpclog/payload'

module Grpclog
  class Error < StandardError; end
  # Your code goes here...
end
