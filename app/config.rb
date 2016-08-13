class Config
  @@config = nil
  class << self
    def get value
      if @@config.nil?
        @@config = YAML.load_file('data/config.yml')
      end
      @@config[value]
    end
  end
end
