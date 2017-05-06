##
# Class for storing user logs

class Log
  @@logs = []

  class << self

    ##
    # Create log entry for +user+ in a format {user, log, type, time}.
    # This object will be sent to user(frontend javascript).
    # There are must be some 'system' or 'all' user to send logs to everybody
    # for login messages etc

    def push user, message, type
      log_entry = {:user => user, :message => message, :type => type, :time => Time.now.strftime("%Y.%m.%d %H:%M:%S")}
      @@logs.push(log_entry)
      log_entry
    end

    ##
    # Select log entry for +user+
    def get_by_user user
      @@logs.select{ |l| l[:user] == user }
    end
  end
end
