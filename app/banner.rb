class Banner
  attr_reader :id, :user, :mod_max_hp, :mod_max_ap, :mod_attack
  @@id_seq = 1
  # id -> unit
  @@banners = {}

  def initialize user
    @id = @@id_seq
    @@id_seq += 1
    @mod_max_hp = 1
    @mod_max_ap = 1
    @mod_attack = 1
    @user = user
  end

  def to_hash()
    hash = {}
    self.instance_variables.each do |var|
      unless var == :@user
        hash[var] = self.instance_variable_get var
      end
    end
    if @user
      hash[:@user_name] = @user.login
      hash[:@user_id] = @user.id
    end
    hash
  end

  def to_json(generator = JSON.generator)
    to_hash().to_json
  end

  class << self
    def new user
      banner = super user
      @@banners[banner.id] = banner
    end

    def get_first_by_user user
      @@banners.values.select{|banner| banner.user.id == user.id}.first
    end

    def get_by_user(user)
      @@banners.values.select{|banner| banner.user.id == user.id}
    end
    
  end
end
