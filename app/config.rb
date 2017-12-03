require 'yaml'

class Config
  @@config = nil

  class << self
    def[](key)
      get(key)
    end

    ##
    # +left+ hash, +right+ hash

    def merge(left, right)
      if left.respond_to? :each
        left.each{|key, value|
          if right.has_key?(key)
            if value.respond_to? :each
              merge(left[key], right[key])
            else
              left[key] = right[key]
            end
          end
        }
      else
        left[key] = right[key]
      end
    end

    def load_config
      # default is for production
      @@config = YAML.load_file('app/config/default.yml')
      env = nil
      if ENV['ORBS_ENV']
        env = ENV['ORBS_ENV']
      elsif ENV['RACK_ENV']
        env = ENV['RACK_ENV']
      end
      if ['test', 'development'].include?(env)
        config = YAML.load_file("app/config/#{env}.yml")
        merge(@@config, config)
      end
      @@config
    end

    def get(key)
      if @@config.nil?
        load_config
      end
      @@config[key]
    end
  end
end
