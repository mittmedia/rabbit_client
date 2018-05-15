require 'spec_helper'
require 'rabbit_client/publisher'

describe RabbitClient::Publisher do
  describe '.publish_messages' do
    it 'publishes messages to exchange fanout' do
      url = 'localhost'
      exchange = 'test.fxout'
      exchange_type = :fanout
      messages = %w(message1 message2)
      expect(RabbitClient::BunnyClient)
      .to(receive(:publish_messages))
      .with url, exchange, exchange_type, messages
      RabbitClient::Publisher.publish_messages url,
                                               exchange,
                                               messages,
                                               exchange_type: exchange_type
    end

    it 'publishes messages to exchange to direct' do
      url = 'localhost'
      exchange = 'test.fxout'
      exchange_type = :direct
      messages = %w(message1 message2)
      expect(RabbitClient::BunnyClient)
      .to(receive(:publish_messages))
      .with url, exchange, exchange_type, messages
      RabbitClient::Publisher.publish_messages url,
                                               exchange,
                                               messages,
                                               exchange_type: exchange_type
    end

    it 'publishes messages to exchange to topic' do
      url = 'localhost'
      exchange = 'test.fxout'
      exchange_type = :topic
      messages = %w(message1 message2)
      expect(RabbitClient::BunnyClient)
      .to(receive(:publish_messages))
      .with url, exchange, exchange_type, messages
      RabbitClient::Publisher.publish_messages url,
                                               exchange,
                                               messages,
                                               exchange_type: exchange_type
    end

    it 'publishes messages to exchange to topic' do
      url = 'localhost'
      exchange = 'test.fxout'
      exchange_type = :topic
      messages = %w(message1 message2)
      expect(RabbitClient::BunnyClient)
      .to(receive(:publish_messages))
      .with url, exchange, exchange_type, messages
      RabbitClient::Publisher.publish_messages url,
                                               exchange,
                                               messages,
                                               exchange_type: exchange_type
    end


    it 'formats messages as JSON before publishing' do
      message = 'message'
      expect(RabbitClient::BunnyClient)
      .to(receive(:publish_messages))
      .and_yield message
      expect(message)
      .to receive :to_json
      RabbitClient::Publisher.publish_messages 'localhost',
                                               'test.fxout',
                                               message,
                                               format: :json
    end
  end
end
