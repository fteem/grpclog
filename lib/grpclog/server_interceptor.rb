# frozen_string_literal: true

module Grpclog
  class ServerInterceptor < ::GRPC::ServerInterceptor
    def initialize(logger, level = :info)
      @logger = logger
      @level = level

      super()
    end

    # rubocop:disable Lint/UnusedMethodArgument
    def request_response(request: nil, call: nil, method: nil, &block)
      log(method, call, &block)
    end

    def server_streamer(request: nil, call: nil, method: nil, &block)
      log(method, call, &block)
    end

    def client_streamer(call: nil, method: nil, &block)
      log(method, call, &block)
    end

    def bidi_streamer(requests: nil, call: nil, method: nil, &block)
      log(method, call, &block)
    end
    # rubocop:enable all

    private

    def log(method, _call)
      start_time = Time.now
      code = ::GRPC::Core::StatusCodes::OK

      yield
    rescue StandardError => e
      code = e.is_a?(::GRPC::BadStatus) ? e.code : ::GRPC::Core::StatusCodes::UNKNOWN

      raise
    ensure
      payload = Grpclog::Payload.new(method, code, start_time)

      if e
        payload.exception = e.message
        @level = :error
      end

      @logger.formatter = method(:formatter)
      @logger.send(@level, payload.to_h)
    end

    def formatter(_severity, _datetime, _progname, msg)
      JSON.dump(msg)
    end
  end
end
