module Ghost
  module Host
    class AlreadyExists < StandardError; end
    
    class << self
      attr_accessor :adapter
    end
  end
end