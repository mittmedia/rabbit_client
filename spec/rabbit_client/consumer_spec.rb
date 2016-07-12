require 'spec_helper'
require 'rabbit_client/consumer'

Consumer = Class.new RabbitClient::Consumer do
  def consume; end

  def handle_error; end

  def self.max_retries
    5
  end
end

describe RabbitClient::Consumer do
  before :each do
    @consumer = Consumer.new
  end

  describe '#work_with_params' do
    it 'consumes the received message' do
      message = 'message'
      expect(@consumer)
        .to(receive(:consume))
        .with message
      @consumer.work_with_params message, nil, {}
    end

    it 'handles errors when retry count is above limit' do
      message = 'message'
      setup_retry_count 5
      expect(@consumer)
        .to(receive(:consume))
        .and_raise 'error'
      expect(@consumer)
        .to(receive(:handle_error))
        .with instance_of(RuntimeError), message
      expect(RabbitClient::Publisher)
        .to receive :publish_messages
      @consumer.work_with_params message, nil, {}
    end

    it 'handles errors if not retrying' do
      message = 'message'
      allow(RabbitClient::Listener)
        .to(receive(:retry_messages?))
        .and_return false
      expect(@consumer)
        .to(receive(:consume))
        .and_raise 'error'
      expect(@consumer)
        .to(receive(:handle_error))
        .with instance_of(RuntimeError), message
      expect(RabbitClient::Publisher)
        .not_to receive :publish_messages
      @consumer.work_with_params message, nil, {}
    end

    it 'retries messages when retry count is below limit' do
      setup_retry_count 0
      expect(@consumer)
        .to(receive(:consume))
        .and_raise 'error'
      expect(@consumer)
        .to_not receive :handle_error
      @consumer.work_with_params 'message', nil, {}
    end
  end
end

def setup_retry_count(count)
  allow(RabbitClient::Listener)
    .to(receive(:retry_messages?))
    .and_return true
  expect(RabbitClient::MetadataHelper)
    .to(receive(:retry_count))
    .and_return count
end
