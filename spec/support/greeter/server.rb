# frozen_string_literal: true

require 'support/greeter/greeter_services_pb'

module Grpclog
  module Greeter
    class Server < Grpclog::Greeter::Service
      def request_response_method(msg, _call)
        raise_exception(msg)

        Grpclog::Hello.new(name: "Hello #{msg.name}")
      end

      def server_streamer_method(msg, _call)
        raise_exception(msg)

        [Grpclog::Hello.new(name: 'Hello!')]
      end

      def client_streamer_method(call)
        call.each_remote_read do |msg|
          raise_exception(msg)
        end

        Grpclog::Hello.new(name: 'Hello!')
      end

      def bidi_streamer_method(call, _view)
        call.each do |msg|
          raise_exception(msg)
        end

        [Grpclog::Hello.new(name: 'Hello!')]
      end

      def raise_exception(msg)
        code = msg.error_code

        raise ::GRPC::BadStatus.new_status_exception(code, 'test exception') if code > ::GRPC::Core::StatusCodes::OK
        raise code.to_s if code < ::GRPC::Core::StatusCodes::OK
      end
    end
  end
end
