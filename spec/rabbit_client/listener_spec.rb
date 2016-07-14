require 'spec_helper'
require 'rabbit_client/listener'

describe RabbitClient::Listener do
  describe '.configure' do
    it 'configures Sneakers with listener URL' do
      sneakers_opts = { amqp: 'listen_url' }
      mock_configure hash_including(sneakers_opts)
      RabbitClient::Listener.configure listen_url: 'listen_url'
    end

    it 'uses a Maxretry handler by default' do
      sneakers_opts = { handler: Sneakers::Handlers::Maxretry }
      mock_configure hash_including(sneakers_opts)
      RabbitClient::Listener.configure listen_url: 'listen_url'
    end

    it "doesn't use a Maxretry handler if not retrying messages" do
      sneakers_opts = { handler: Sneakers::Handlers::Maxretry }
      mock_configure hash_excluding(sneakers_opts)
      RabbitClient::Listener.configure listen_url: 'listen_url',
                                       retry_messages: false
    end

    it 'passes used options to Sneakers' do
      sneakers_opts = { daemonize: true }
      mock_configure hash_including(sneakers_opts)
      RabbitClient::Listener.configure listen_url: 'listen_url',
                                       daemonize: true
    end

    it 'uses passed options over default options' do
      sneakers_opts = { workers: 10 }
      mock_configure hash_including(sneakers_opts)
      RabbitClient::Listener.configure listen_url: 'listen_url',
                                       workers: 10
    end

    def mock_configure(args)
      expect(Sneakers)
        .to(receive(:configure))
        .with args
    end
  end
end
