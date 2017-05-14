##
# Application logs

module Logging
  @logger = nil

  # This is the magical bit that gets mixed into your classes
  def logger
    Logging.logger
  end

  # Global, memoized, lazy initialized instance of a logger
  def self.logger
    unless @logger
      @logger = Logger.new(Config.get('log'), 'weekly')
      @logger.level = Logger::DEBUG
    end
    @logger
  end
end
