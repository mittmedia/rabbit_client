require 'sneakers'
require 'rabbit_client/publisher'
require 'rabbit_client/listener'
require 'rabbit_client/metadata_helper'

module RabbitClient
  class Consumer
    include Sneakers::Worker

    class << self
      attr_reader :queue_name

      def configure(opts)
        @queue_name = opts[:queue]
        configuration = {
          exchange: opts[:exchange],
          exchange_type: opts[:exchange_type] || 'fanout',
          heartbeat: opts[:heartbeat] || 60,
          arguments: { :'x-dead-letter-exchange' => "#{@queue_name}-retry" }
        }
        configuration[:metrics] = opts[:metrics] if opts[:metrics]
        from_queue @queue_name, configuration
      end
    end

    def work_with_params(message, _delivery_info, metadata)
      RabbitClient.logger.debug { "Fetched message from queue: #{message}" }
      consume message
      ack!
    rescue => e
      log_error e, message
      retries = retry_count metadata
      if Listener.retry_messages? && retries < max_retries
        tries_left = max_retries - retries
        RabbitClient.logger.info { "Retrying message #{tries_left} more times" }
        reject!
      else
        handle_error e, message if defined? handle_error
        publish_error message
        ack!
      end
    end

    private

    def max_retries
      Listener.max_retries
    end

    def retry_count(metadata)
      MetadataHelper.retry_count metadata, self.class.queue_name
    end

    def publish_error(message)
      return unless Listener.retry_messages?
      Publisher.publish_messages Listener.listen_url,
                                 "#{self.class.queue_name}-error",
                                 message,
                                 exchange_type: :topic
    end

    def log_error(e, message)
      RabbitClient.logger.error { "Error while processing message: #{e}" }
      RabbitClient.logger.error e.backtrace.join "\n"
      RabbitClient.logger.error { "Message: #{message}" }
    end
  end
end
