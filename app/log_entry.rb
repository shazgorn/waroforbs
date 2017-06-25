require_relative 'jsonable'

class LogEntry < JSONable

  attr_accessor :user, :type

  def initialize type, message, user = nil
    @message = message
    @type = type
    @user = user
    @time = Time.now.strftime("%Y.%m.%d %H:%M:%S")
  end

  class << self
    def ok message
      self.new :ok, message
    end

    def error message
      self.new :error, message
    end

    def move unit_id, dx, dy, new_x, new_y
      message = "Unit #%d moved by %d, %d to %d:%d" % [unit_id, dx, dy, new_x, new_y]
      self.new :move, message
    end
  end
end
