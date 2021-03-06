require 'i18n'
require 'log_entry'
require 'exception'

##
# Class for storing user logs

class LogBox
  @@logs = []
  # buffer for current request
  @@unread_logs = {}

  class << self

    ##
    # Create log entry for +user+ in a format {user, log, type, time}.
    # This hash(object) will be sent to user(frontend javascript).
    # There are must be some 'system' or 'all' or 'broadcast' type
    # to send logs to everybody login messages for example

    def push(type, message, user)
      log_entry = LogEntry.new(type, message, user)
      push_entry(log_entry)
    end

    def push_entry(log_entry)
      raise OrbError, 'No user in log_entry' unless log_entry.user
      @@logs << log_entry
      unless @@unread_logs.key?(log_entry.user.id)
        @@unread_logs[log_entry.user.id] = []
      end
      @@unread_logs[log_entry.user.id] << log_entry
      log_entry
    end

    def error(message, user)
      push_entry(LogEntry.error(message, user))
    end

    def move(unit_id, dx, dy, new_x, new_y, user)
      push_entry(LogEntry.move(unit_id, dx, dy, new_x, new_y, user))
    end

    def spawn(message, user)
      push_entry(LogEntry.spawn(message, user))
    end

    def attack(res, user)
      push_entry(LogEntry.attack(res, user))
    end

    def defence(res, user)
      push_entry(LogEntry.defence(res, user))
    end

    ##
    # Select log entry for +user+

    def get_by_user(user)
      @@logs.select{ |l| l.user.id == user.id }
    end

    ##
    # Get logs for current request (buffer)
    #

    def get_current_by_user(user)
      logs = @@unread_logs[user.id]
      @@unread_logs.delete(user.id)
      logs
    end
  end
end
