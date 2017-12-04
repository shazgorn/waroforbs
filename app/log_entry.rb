require 'jsonable'

class LogEntry < JSONable

  attr_accessor :user, :type
  attr_reader :message

  def initialize(type, message, user = nil, res = nil)
    @message = message
    @type = type
    @user = user
    t = Time.now
    @time = t.strftime("%Y.%m.%d %H:%M:%S")
    @iso_time = t.iso8601
    # log detailed information (Result!)
    @res = res
  end

  def to_hash
    {
      :message => @message,
      :type => @type,
      :time => @time,
      :iso_time => @iso_time,
      :res => @res
    }
  end

  class << self
    def error(message, user = nil)
      self.new(:error, message, user)
    end

    def move(unit_id, dx, dy, new_x, new_y, user)
      message = I18n.t('log_entry_move', unit_id: unit_id, dx: dx, dy: dy, new_x: new_x, new_y: new_y)
      self.new(:move, message, user)
    end

    def spawn(message, user = nil)
      self.new(:spawn, message, user)
    end

    def attack(res, user = nil)
      message = ''
      if res[:d_casualties][:killed]
        message += I18n.t('log_entry_enemy_unit_killed') + '. '
      end
      message += I18n.t('log_entry_damage_dealt', d_wounds: res[:d_casualties][:wounds], d_kills: res[:d_casualties][:kills], a_wounds: res[:a_casualties][:wounds], a_kills: res[:a_casualties][:kills])
      if res[:a_casualties][:killed]
        message += '. ' + I18n.t('log_entry_unit_lost') + '.'
      end
      self.new(:attack, message, user, res)
    end

    def defence(res, user = nil)
      message = ''
      if res[:a_casualties][:killed]
        message += I18n.t('log_entry_enemy_unit_killed') + '. '
      end
      message += I18n.t('log_entry_damage_taken', d_wounds: res[:d_casualties][:wounds], d_kills: res[:d_casualties][:kills], a_wounds: res[:a_casualties][:wounds], a_kills: res[:a_casualties][:kills])
      if res[:d_casualties][:killed]
        message += '. ' + I18n.t('log_entry_unit_lost') + '.'
      end
      self.new(:defence, message, user, res)
    end
  end
end
