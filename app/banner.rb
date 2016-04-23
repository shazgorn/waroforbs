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

  class << self
    def new user
      banner = super user
      @@banners[banner.id] = banner
    end

    def get_first_by_user user
      @@banners.values.select{|banner| banner.user.id == user.id}.first
    end
  end
end
