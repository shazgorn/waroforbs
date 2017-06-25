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
      push_entry log_entry = LogEntry.new(type, message, user).to_hash
    end

    def push_entry log_entry
      @@logs.push(log_entry.to_hash)
      log_entry.to_hash
    end

    def error message, user
      push_entry LogEntry.error message, user
    end

    def move unit_id, dx, dy, new_x, new_y, user
      msg = "Unit #%d moved by %d, %d to %d:%d" % [unit_id, dx, dy, new_x, new_y]
      push user, msg, :move
    end

    ##
    # Select log entry for +user+
    def get_by_user user
      @@logs.select{ |l| l.user == user }
    end
  end
end
