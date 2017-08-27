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

    def move(unit_id, dx, dy, new_x, new_y, user)
      message = I18n.t('log_entry_move', unit_id: unit_id, dx: dx, dy: dy, new_x: new_x, new_y: new_y)
      #message = "Unit #%d moved by %d, %d to %d:%d" % [unit_id, dx, dy, new_x, new_y]
      self.new(:move, message, user)
    end

    def spawn(message, user = nil)
      self.new(:spawn, message, user)
    end

    def attack(res, user = nil)
      message = "Damage dealt: %d, %d. Damage taken: %d, %d." % [res[:d_dmg][:wounds], res[:d_dmg][:kills], res[:a_dmg][:wounds], res[:a_dmg][:kills]]
      if res[:d_dmg][:dead]
        message += ' Your hero has been killed.'
      end
      self.new(:attack, message, user)
    end

    def defence(res, user = nil)
      message = "Damage taken: %d, %d. Damage dealt: %d, %d" % [res[:a_dmg][:wounds], res[:a_dmg][:kills], res[:d_dmg][:wounds], res[:d_dmg][:kills]]
      if res[:a_dmg][:dead]
        message += ' Your hero has been killed.'
      end
      self.new(:defence, message, user)
    end
  end
end
