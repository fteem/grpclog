# frozen_string_literal: true

require 'google/protobuf/empty_pb'
require 'google/protobuf/wrappers_pb'

RSpec.describe Grpclog::ServerInterceptor do
  subject(:logger) { Logger.new($stdout) }

  let(:rpc_class) do
    Class.new do
      include GRPC::GenericService

      self.marshal_class_method = :encode
      self.unmarshal_class_method = :decode
      self.service_name = 'test.Test'

      rpc :Greet, Google::Protobuf::StringValue, Google::Protobuf::Empty
    end
  end

  let(:service_class) do
    Class.new(rpc_class) do
      def greet(_msg, _call)
        # Do nothing
      end
    end
  end

  let(:method) { service_class.new.method(:greet) }
  let(:request) { double }
  let(:call) { instance_double('GRPC::ActiveCall', peer: '', metadata: {}) }

  let(:interceptor) { described_class.new(logger) }

  describe '#request_response_method' do
    before { allow(logger).to receive(:send) }

    context 'when no exception occurs' do
      before { interceptor.request_response(request: request, call: call, method: method) {} }

      it { is_expected.to have_received(:send).with(:info, Hash) }
    end

    context 'when a known exception occurs' do
      before do
        expect do
          interceptor.request_response(request: request, call: call, method: method) do
            raise GRPC::NotFound
          end
        end.to raise_error(GRPC::NotFound)
      end

      it { is_expected.to have_received(:send).with(:error, Hash) }
    end

    context 'when an unknown exception occurs' do
      before do
        expect do
          interceptor.request_response(request: request, call: call, method: method) { raise :unknown }
        end.to raise_error(StandardError)
      end

      it { is_expected.to have_received(:send).with(:error, Hash) }
    end
  end

  describe '#server_streamer' do
    before { allow(logger).to receive(:send) }

    context 'when no exception occurs' do
      before { interceptor.server_streamer(request: request, call: call, method: method) {} }

      it { is_expected.to have_received(:send).with(:info, Hash) }
    end

    context 'when a known exception occurs' do
      before do
        expect do
          interceptor.server_streamer(request: request, call: call, method: method) do
            raise GRPC::NotFound
          end
        end.to raise_error(GRPC::NotFound)
      end

      it { is_expected.to have_received(:send).with(:error, Hash) }
    end

    context 'when an unknown exception occurs' do
      before do
        expect do
          interceptor.server_streamer(request: request, call: call, method: method) { raise :unknown }
        end.to raise_error(StandardError)
      end

      it { is_expected.to have_received(:send).with(:error, Hash) }
    end
  end

  describe '#client_streamer' do
    before { allow(logger).to receive(:send) }

    context 'when no exception occurs' do
      before { interceptor.client_streamer(call: call, method: method) {} }

      it { is_expected.to have_received(:send).with(:info, Hash) }
    end

    context 'when a known exception occurs' do
      before do
        expect do
          interceptor.server_streamer(call: call, method: method) do
            raise GRPC::NotFound
          end
        end.to raise_error(GRPC::NotFound)
      end

      it { is_expected.to have_received(:send).with(:error, Hash) }
    end

    context 'when an unknown exception occurs' do
      before do
        expect do
          interceptor.server_streamer(call: call, method: method) { raise :unknown }
        end.to raise_error(StandardError)
      end

      it { is_expected.to have_received(:send).with(:error, Hash) }
    end
  end

  describe '#bidi_streamer' do
    before { allow(logger).to receive(:send) }

    context 'when no exception occurs' do
      before { interceptor.bidi_streamer(requests: [request], call: call, method: method) {} }

      it { is_expected.to have_received(:send).with(:info, Hash) }
    end

    context 'when a known exception occurs' do
      before do
        expect do
          interceptor.bidi_streamer(requests: [request], call: call, method: method) do
            raise GRPC::NotFound
          end
        end.to raise_error(GRPC::NotFound)
      end

      it { is_expected.to have_received(:send).with(:error, Hash) }
    end

    context 'when an unknown exception occurs' do
      before do
        expect do
          interceptor.bidi_streamer(requests: [request], call: call, method: method) { raise :unknown }
        end.to raise_error(StandardError)
      end

      it { is_expected.to have_received(:send).with(:error, Hash) }
    end
  end
end
