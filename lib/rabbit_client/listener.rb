require 'sneakers/runner'
require 'sneakers/handlers/maxretry'
require 'rabbit_client'

module RabbitClient
  module Listener
    def self.configure(opts)
      @listen_url = opts[:listen_url]
      @retry_messages = opts[:retry_messages] == false ? false : true
      opts = {
        amqp: @listen_url,
        daemonize: false,
        log: RabbitClient.logger,
        workers: opts[:workers] || 1,
        prefetch: opts[:prefetch] || 1,
        threads: opts[:threads] || 1,
        retry_timeout: opts[:retry_timeout] || 60 * 1000
      }
      opts[:handler] = Sneakers::Handlers::Maxretry if @retry_messages
      Sneakers.configure opts
    end

    def self.listen(consumers)
      consumers = [consumers] unless consumers.is_a? Array
      runner = Sneakers::Runner.new consumers
      runner.run
    end

    def self.listen_url
      @listen_url
    end

    def self.retry_messages?
      @retry_messages
    end
  end
end
