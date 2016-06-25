require 'rabbit_client/bunny_client'

module RabbitClient
  module Publisher
    def self.publish_messages(url, exchange_name, messages, opts = {})
      count = messages.is_a?(Array) ? messages.size : 1
      RabbitClient.logger.info { "Publishing #{count} messages to exchange #{exchange_name}" }
      BunnyClient.publish_messages url,
                                   exchange_name,
                                   opts[:exchange_type],
                                   messages do |message|
        RabbitClient.logger.debug { "Publishing message to exchange #{exchange_name}: #{message}" }
        format_message message, opts[:format]
      end
    end

    def self.format_message(message, format)
      case format
      when :json
        message.to_json
      else
        message
      end
    end
    private_class_method :format_message
  end
end
