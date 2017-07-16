require 'jsonable'

class LogEntry < JSONable

  attr_accessor :user, :type
  attr_reader :message

  def to_hash
    {
      :message => @message,
      :type => @type,
      :time => @time
    }
  end

  def initialize type, message, user = nil
    @message = message
    @type = type
    @user = user
    @time = Time.now.strftime("%Y.%m.%d %H:%M:%S")
  end

  class << self
    def error message, user = nil
      self.new :error, message, user
    end

    def move unit_id, dx, dy, new_x, new_y, user = nil
      message = "Unit #%d moved by %d, %d to %d:%d" % [unit_id, dx, dy, new_x, new_y]
      self.new :move, message, user
    end

    def spawn message, user = nil
      self.new :spawn, message, user
    end
  end
end
