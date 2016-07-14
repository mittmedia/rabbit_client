require 'sneakers/runner'
require 'sneakers/handlers/maxretry'
require 'rabbit_client'

module RabbitClient
  module Listener
    def self.configure(opts)
      sneakers_opts = build_opts opts
      @listen_url = sneakers_opts[:listen_url]
      @retry_messages = sneakers_opts[:retry_messages]
      Sneakers.configure sneakers_opts
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

    def self.build_opts(opts)
      retry_messages = opts[:retry_messages] == false ? false : true
      opts[:handler] = Sneakers::Handlers::Maxretry if retry_messages
      opts[:amqp] = opts[:listen_url]
      default_opts.merge opts
    end
    private_class_method :build_opts

    def self.default_opts
      {
        daemonize: false,
        log: RabbitClient.logger,
        workers: 1,
        prefetch: 1,
        threads: 1,
        retry_timeout: 60 * 1000
      }
    end
    private_class_method :default_opts
  end
end
