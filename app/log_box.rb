require_relative 'log_entry'
require_relative 'exception'

##
# Class for storing user logs

class LogBox
  @@logs = []

  class << self

    ##
    # Create log entry for +user+ in a format {user, log, type, time}.
    # This hash(object) will be sent to user(frontend javascript).
    # There are must be some 'system' or 'all' or 'broadcast' type
    # to send logs to everybody login messages for example

    def push type, message, user
      log_entry = LogEntry.new(type, message, user)
      push_entry log_entry
    end

    def push_entry log_entry
      @@logs << log_entry
      log_entry
    end

    def << log_entry
      raise OrbError, 'No user in log_entry' unless log_entry.user
      @@logs << log_entry
      log_entry
    end

    def error message, user
      push_entry LogEntry.error message, user
    end

    def move unit_id, dx, dy, new_x, new_y, user
      msg = "Unit #%d moved by %d, %d to %d:%d" % [unit_id, dx, dy, new_x, new_y]
      push user, msg, :move
    end

    def spawn message, user
      push_entry LogEntry.spawn message, user
    end

    ##
    # Select log entry for +user+

    def get_by_user user
      @@logs.select{ |l| l.user.id == user.id }
    end
  end
end
