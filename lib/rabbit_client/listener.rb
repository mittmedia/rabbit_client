require 'sneakers/runner'
require 'sneakers/handlers/maxretry'
require 'rabbit_client'

module RabbitClient
  module Listener
    def self.configure(opts)
      @listen_url = opts[:listen_url]
      Sneakers.configure amqp: @listen_url,
                         daemonize: false,
                         log: RabbitClient.logger,
                         workers: opts[:workers] || 1,
                         prefetch: opts[:prefetch] || 1,
                         threads: opts[:threads] || 1,
                         handler: Sneakers::Handlers::Maxretry,
                         retry_timeout: opts[:retry_timeout] || 60 * 1000
    end

    def self.listen(consumers)
      consumers = [consumers] unless consumers.is_a? Array
      runner = Sneakers::Runner.new consumers
      runner.run
    end

    def self.listen_url
      @listen_url
    end
  end
end
