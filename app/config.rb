class Config
  @@config = nil
  class << self
    def get value
      if @@config.nil?
        @@config = YAML.load_file('config/app.default.yml')
                     .merge!(YAML.load_file('config/app.yml'))
      end
      @@config[value]
    end
  end
end
