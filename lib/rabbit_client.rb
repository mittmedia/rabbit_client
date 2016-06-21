require 'rabbit_client/version'
require 'logger'

module RabbitClient
  @config = {}

  def self.configure(opts)
    @config = opts
  end

  def self.logger
    @logger ||= setup_logger
  end

  def self.log_level
    @log_level ||= @config[:log_level] || Logger::INFO
  end

  def self.setup_logger
    return @config[:logger] if @config[:logger]
    logger = Logger.new STDOUT
    logger.level = log_level
    logger
  end
  private_class_method :setup_logger
end
