module Ghost
  module Host
    class AlreadyExists < StandardError; end
    
    class << self
      attr_accessor :adapter
    end
    
    def self.add(*args)
      adapter.add(*args)
    end
    
    attr_reader :host, :ip
    
    alias :to_s     :host
    alias :hostname :host
    alias :name     :host
    
    
    def initialize(host, ip=nil)
      @host = host
      @ip = ip
    end
    
    def ==(other)
      @host == other.host && @ip = other.ip
    end
  end
end