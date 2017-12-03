require 'yaml'

class Config
  @@config = nil
  class << self
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
      @@config = YAML.load_file('config/app.default.yml')
      config = YAML.load_file('config/app.yml')
      merge(@@config, config)
      @@config
    end

    def get value
      if @@config.nil?
        load_config
      end
      @@config[value]
    end
  end
end
