require 'bunny'

module RabbitClient
  module BunnyClient
    def self.publish_messages(url, exchange_name, exchange_type, messages)
      connect url, exchange_name, exchange_type do |exchange|
        publish exchange, messages do |message|
          yield message if block_given?
        end
      end
    end

    def self.connect(url, exchange_name, exchange_type)
      connection = Bunny.new url
      connection.start
      channel = connection.create_channel
      exchange = create_exchange channel,
                                 exchange_name,
                                 exchange_type
      yield exchange
    ensure
      connection.close
    end
    private_class_method :connect

    def self.create_exchange(channel, name, type)
      case type
      when :topic
        channel.topic name, durable: true
      else
        channel.fanout name, durable: true
      end
    end
    private_class_method :create_exchange

    def self.publish(exchange, messages)
      messages = [messages] unless messages.is_a? Array
      messages.each do |message|
        message = yield message
        exchange.publish message
      end
    end
    private_class_method :publish
  end
end
