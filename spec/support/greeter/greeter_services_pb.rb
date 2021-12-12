# frozen_string_literal: true

# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: spec/support/greeter/greeter.proto for package 'grpclog'

require 'grpc'
require 'support/greeter/greeter_pb'

module Grpclog
  module Greeter
    class Service
      include ::GRPC::GenericService

      self.marshal_class_method = :encode
      self.unmarshal_class_method = :decode
      self.service_name = 'grpclog.Greeter'

      rpc :RequestResponseMethod, ::Grpclog::Hello, ::Grpclog::Hello
      rpc :ServerStreamerMethod, ::Grpclog::Hello, stream(::Grpclog::Hello)
      rpc :ClientStreamerMethod, stream(::Grpclog::Hello), ::Grpclog::Hello
      rpc :BidiStreamerMethod, stream(::Grpclog::Hello), stream(::Grpclog::Hello)
    end

    Stub = Service.rpc_stub_class
  end
end