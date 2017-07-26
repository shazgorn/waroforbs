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

  def initialize(type, message, user = nil)
    @message = message
    @type = type
    @user = user
    @time = Time.now.strftime("%Y.%m.%d %H:%M:%S")
  end

  class << self
    def error(message, user = nil)
      self.new(:error, message, user)
    end

    def move(unit_id, dx, dy, new_x, new_y, user = nil)
      message = "Unit #%d moved by %d, %d to %d:%d" % [unit_id, dx, dy, new_x, new_y]
      self.new(:move, message, user)
    end

    def spawn(message, user = nil)
      self.new(:spawn, message, user)
    end

    def attack(res, user = nil)
      message = "damage dealt dmg: %d, damage taken ca_dmg: %d" % [res[:a_data][:dmg], res[:a_data][:ca_dmg]]
      if res[:a_data][:dead]
        message += '. Your hero has been killed.'
      end
      self.new(:attack, message, user)
    end

    def defence(res, user = nil)
      message = "damage taken ca_dmg: %d, damage dealt dmg: %d" % [res[:d_data][:ca_dmg], res[:d_data][:dmg]]
      if res[:d_data][:dead]
        message += '. Your hero has been killed.'
      end
      self.new(:defence, message, user)
    end
  end
end
