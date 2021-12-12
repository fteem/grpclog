# frozen_string_literal: true

require './spec/support/greeter'

RSpec.describe Grpclog::Payload do
  subject(:payload) { described_class.new(method, code, start_time).to_h }

  let(:service_class) do
    Class.new(Grpclog::Greeter::Service) do
      def self.name
        'TestModule::TestService'
      end

      def request_response_method(_msg, _call)
        # Do nothing
      end
    end
  end

  let(:method) { service_class.new.method(:request_response_method) }
  let(:code) { GRPC::Core::StatusCodes::OK }
  let(:start_time) { Time.now }

  describe 'fields' do
    describe 'grpc.service' do
      subject { payload['grpc.service'] }

      it { is_expected.to eq 'grpclog.Greeter' }
    end

    describe 'grpc.method' do
      subject { payload['grpc.method'] }

      it { is_expected.to eq 'RequestResponseMethod' }
    end

    describe 'grpc.code' do
      subject { payload['grpc.code'] }

      it { is_expected.to eq 'OK' }
    end

    describe 'grpc.start_time' do
      subject { payload['grpc.start_time'] }

      it { is_expected.to be_a Time }
    end

    describe 'grpc.time_ms' do
      subject { payload['grpc.time_ms'] }

      it { is_expected.to be_a Float }
    end

    describe 'pid' do
      subject { payload['pid'] }

      it { is_expected.to eq Process.pid }
    end
  end
end
