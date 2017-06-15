module Cli
  def stop
    if File.exist?(Config.get('pid'))
      pid = nil
      File.open(Config.get('pid')) {|file|
        pid = file.readline.to_i
      }
      begin
        if pid
          Process.kill("HUP", pid)
        end
      rescue Errno::ESRCH => e
        Logging.logger.info "%s with pid %d" % [e.message, pid]
      end
    end
  end

  def check_args
    ARGV.each{|k|
      case k
      when 'gen'
        @generate = true
      when 'stop'
        stop
        exit
      end
    }
    File.open(Config.get('pid'), 'w') {|f|
      f.write Process.pid
    }
  end
end
