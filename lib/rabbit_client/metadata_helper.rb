module RabbitClient
  module MetadataHelper
    def self.retry_count(metadata, queue_name)
      headers = metadata[:headers]
      return 0 unless headers && headers['x-death']
      header = headers['x-death']
      header.find { |h| h['exchange'] == "#{queue_name}-retry" }['count']
    end
  end
end
