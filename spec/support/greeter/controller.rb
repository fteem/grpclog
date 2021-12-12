# frozen_string_literal: true

# rubocop:disable Style/ClassVars
module Grpclog
  module Greeter
    class Controller
      @@port = 0

      class << self
        def next_port
          @@port += 1
        end
      end

      attr_reader :host

      def initialize(interceptors: [], service: Server)
        @host = "0.0.0.0:8008#{self.class.next_port}"
        @server = GRPC::RpcServer.new(
          poll_period: 1,
          pool_keep_alive: 1,
          interceptors: interceptors
        )
        @server.add_http2_port(host, :this_port_is_insecure)
        @server.handle(service)
      end

      def start
        @server_thread = Thread.new { @server.run_till_terminated }
      end

      def stop
        @server.stop
        @server_thread.join
        @server_thread.terminate
      end
    end
  end
end
# rubocop:enable all
