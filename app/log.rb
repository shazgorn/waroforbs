# User offline log
class Log
  @@logs = []

  class << self
    def log user, log_str
      @@logs.push({:user => user, :log => log_str, :time => Time.now.strftime("%Y.%m.%d %H:%M:%S")})
    end

    def get_by_user user
      @@logs.select{ |l| l[:user] == user }
    end
  end
end
