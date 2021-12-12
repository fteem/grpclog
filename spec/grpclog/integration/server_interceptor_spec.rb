# frozen_string_literal: true

require './spec/support/greeter'

# rubocop:disable RSpec/InstanceVariable
RSpec.describe Grpclog::ServerInterceptor do
  subject(:message) { JSON.parse(log.string) }

  let(:log) { StringIO.new }
  let(:logger) { Logger.new(log) }

  let(:client) do
    Grpclog::Greeter::Stub.new(
      @server.host,
      :this_channel_is_insecure,
      channel_override: channel,
      interceptors: []
    )
  end

  let(:interceptor) { described_class.new(logger) }
  let(:channel) { GRPC::Core::Channel.new(@server.host, nil, :this_channel_is_insecure) }

  before do
    @server = Grpclog::Greeter::Controller.new(interceptors: [interceptor])
    @server.start
  end

  after do
    @server&.stop
  end

  describe '#request_response_method' do
    before { client.request_response_method(Grpclog::Hello.new) }

    it { is_expected.to include('grpc.code' => 'OK') }
  end

  describe '#server_streamer_method' do
    context 'when no exceptions are raised' do
      before do
        enumerator = client.server_streamer_method(Grpclog::Hello.new)
        enumerator.each {} # Consume the stream
      end

      it { is_expected.to include('grpc.code' => 'OK') }
    end

    context 'when an exception is raised' do
      before do
        expect do
          enumerator = client.server_streamer_method(
            Grpclog::Hello.new(error_code: ::GRPC::Core::StatusCodes::UNKNOWN)
          )
          enumerator.each {} # Consume the stream
        end.to raise_error(::GRPC::Unknown)
      end

      it { is_expected.to include('grpc.code' => 'Unknown') }
    end
  end

  describe '#client_streamer_method' do
    context 'when no exceptions are raised' do
      before { client.client_streamer_method([Grpclog::Hello.new]) }

      it { is_expected.to include('grpc.code' => 'OK') }
    end

    context 'when an exception is raised' do
      before do
        expect do
          enumerator = client.client_streamer_method(
            [Grpclog::Hello.new(error_code: ::GRPC::Core::StatusCodes::INVALID_ARGUMENT)]
          )
          enumerator.each {} # Consume the stream
        end.to raise_error(::GRPC::InvalidArgument)
      end

      it { is_expected.to include('grpc.code' => 'InvalidArgument') }
    end
  end

  describe '#bidi_streamer_method' do
    context 'when no exceptions are raised' do
      before do
        enumerator = client.bidi_streamer_method([Grpclog::Hello.new])
        enumerator.each {} # Consume the stream
      end

      it { is_expected.to include('grpc.code' => 'OK') }
    end

    context 'when an exception is raised' do
      before do
        expect do
          enumerator = client.bidi_streamer_method(
            [Grpclog::Hello.new(error_code: ::GRPC::Core::StatusCodes::OUT_OF_RANGE)]
          )
          enumerator.each {} # Consume the stream
        end.to raise_error(GRPC::OutOfRange)
      end

      it { is_expected.to include('grpc.code' => 'OutOfRange') }
    end
  end
end
# rubocop:enable all
