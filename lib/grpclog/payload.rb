# frozen_string_literal: true

module Grpclog
  class Payload
    CODES = {
      ::GRPC::Core::StatusCodes::OK => 'OK',
      ::GRPC::Core::StatusCodes::CANCELLED => 'Canceled',
      ::GRPC::Core::StatusCodes::UNKNOWN => 'Unknown',
      ::GRPC::Core::StatusCodes::INVALID_ARGUMENT => 'InvalidArgument',
      ::GRPC::Core::StatusCodes::DEADLINE_EXCEEDED => 'DeadlineExceeded',
      ::GRPC::Core::StatusCodes::NOT_FOUND => 'NotFound',
      ::GRPC::Core::StatusCodes::ALREADY_EXISTS => 'AlreadyExists',
      ::GRPC::Core::StatusCodes::PERMISSION_DENIED => 'PermissionDenied',
      ::GRPC::Core::StatusCodes::RESOURCE_EXHAUSTED => 'ResourceExhausted',
      ::GRPC::Core::StatusCodes::FAILED_PRECONDITION => 'FailedPrecondition',
      ::GRPC::Core::StatusCodes::ABORTED => 'Aborted',
      ::GRPC::Core::StatusCodes::OUT_OF_RANGE => 'OutOfRange',
      ::GRPC::Core::StatusCodes::UNIMPLEMENTED => 'Unimplemented',
      ::GRPC::Core::StatusCodes::INTERNAL => 'Internal',
      ::GRPC::Core::StatusCodes::UNAVAILABLE => 'Unavailable',
      ::GRPC::Core::StatusCodes::DATA_LOSS => 'DataLoss',
      ::GRPC::Core::StatusCodes::UNAUTHENTICATED => 'Unauthenticated'
    }.freeze

    attr_accessor :exception
    attr_reader :method, :service, :code, :start_time

    def initialize(method, code, start_time)
      @service = service_name(method)
      @method = method_name(method)
      @code = code
      @start_time = start_time
    end

    def to_h
      result = {
        'grpc.service' => service,
        'grpc.method' => method,
        'grpc.code' => CODES.fetch(code, code.to_s),
        'grpc.start_time' => start_time.utc,
        'grpc.time_ms' => elapsed_milliseconds,
        'pid' => Process.pid
      }
      result.merge!('exception' => exception) if exception
      result
    end

    private

    def elapsed_milliseconds
      (Time.now - start_time) * 1000.0
    end

    def method_name(method)
      owner = method.owner
      method_name, = owner.rpc_descs.find do |k, _|
        ::GRPC::GenericService.underscore(k.to_s) == method.name.to_s
      end

      return '(unknown)' if method_name.nil?

      method_name.to_s
    end

    def service_name(method)
      method.owner.service_name
    end
  end
end
