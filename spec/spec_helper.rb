$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rabbit_client'

logger = Logger.new File::NULL
RabbitClient.configure logger: logger
