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

    def self.publish_message(url, exchange_name, exchange_type, message, routing_key, batch)
      connect url, exchange_name, exchange_type do |exchange|

        current_time = Time.now.getutc
        organization = message.organization

        message_headers = {}

        message_headers[:routing_key] = routing_key
        message_headers[:organization] = organization
        message_headers[:batch] = batch

        message.extra_properties.each do |name, value|
          message_headers[name] = value
        end

        exchange.publish(message.body.to_json,
                         headers: message_headers,
                         routing_key: routing_key,
                         timestamp: current_time.to_i,
                         content_type: 'application/json',
                         type: message.type)
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
      when :direct
        channel.direct name, durable: true
      when :headers
        channel.headers name, durable: true
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
