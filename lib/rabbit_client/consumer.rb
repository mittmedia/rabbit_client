require 'sneakers'
require 'rabbit_client/publisher'

module RabbitClient
  class Consumer
    include Sneakers::Worker

    class << self
      attr_reader :queue_name, :max_retries

      def configure(opts)
        @queue_name = opts[:queue]
        @max_retries = opts[:max_retries] || 5
        configuration = {
          exchange: opts[:exchange],
          exchange_type: opts[:exchange_type] || 'fanout',
          hearbeat: opts[:heartbeat] || 120,
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
      retries = retry_count metadata[:headers]
      if retries < self.class.max_retries
        tries_left = self.class.max_retries - retries
        RabbitClient.logger.info { "Retrying message #{tries_left} more times" }
        reject!
      else
        handle_error e, message if defined? handle_error
        publish_error message
        ack!
      end
    end

    private

    def retry_count(headers)
      return 0 unless headers && headers['x-death']
      header = headers['x-death']
      header.find { |h| h['exchange'] == "#{self.class.queue_name}-retry" }['count']
    end

    def publish_error(message)
      RabbitClient::Publisher.publish_messages RabbitClient::Listener.listen_url,
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
