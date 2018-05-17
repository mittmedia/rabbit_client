module RabbitClient
  class Message
    attr_accessor :type
    attr_accessor :organization
    attr_accessor :body
    attr_accessor :extra_properties
    attr_accessor :origin
  end
end