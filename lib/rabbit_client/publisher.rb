require 'bunny'

module RabbitClient
  module Publisher
    def self.publish_messages(url, exchange_name, messages, opts = {})
      messages = [messages] unless messages.is_a? Array
      connection = Bunny.new url
      begin
        connection.start
        channel = connection.create_channel
        exchange = create_exchange channel,
                                   exchange_name,
                                   opts[:exchange_type]
        RabbitClient.logger.info do
          "Publishing #{messages.size} messages to exchange #{exchange_name}"
        end
        messages.each do |message|
          RabbitClient.logger.debug do
            "Publishing message to exchange #{exchange_name}: #{message}"
          end
          exchange.publish message.to_json
        end
        RabbitClient.logger.info do
          "Published #{messages.size} messages to exchange #{exchange_name}"
        end
      ensure
        connection.close
      end
    end

    def self.create_exchange(channel, name, type)
      case type
      when :topic
        channel.topic name, durable: true
      else
        channel.fanout name, durable: true
      end
    end
    private_class_method :create_exchange
  end
end
