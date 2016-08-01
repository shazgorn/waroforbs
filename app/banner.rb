##
# Nothing like an ordianry ad but the one that soldiers follows
#
# Banner is linked to unit on unit spawn

class Banner
  attr_accessor :unit
  attr_reader :id, :user, :mod_max_hp, :mod_max_ap, :mod_attack
  @@id_seq = 1
  # id -> banner
  @@banners = {}

  ##
  # +user+ User
  # +unit+ Unit
  def initialize user, unit = nil
    @id = @@id_seq
    @@id_seq += 1
    @mod_max_hp = 1
    @mod_max_ap = 1
    @mod_attack = 1
    @user = user
    @unit = unit
  end

  def to_hash()
    hash = {}
    self.instance_variables.each do |var|
      if var == :@user
        hash[:@user_name] = @user.login
        hash[:@user_id] = @user.id
      elsif var == :@unit
        if @unit
          hash[:@unit_id] = @unit.id
        else
          hash[:@unit_id] = nil
        end
      else
        hash[var] = self.instance_variable_get var
      end
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

    def get_by_id user, banner_id
      @@banners.select{|id, banner|
        banner.user.id == user.id && id == banner_id && banner.unit == nil
      }.fetch(banner_id, nil)
    end

    def get_first_by_user user
      @@banners.values.select{|banner| banner.user.id == user.id}.first
    end

    # Get first banner without company by user
    def get_first_free_by_user user
      @@banners.values.select{|banner| banner.user.id == user.id && banner.unit == nil}.first
    end

    def get_by_user(user)
      @@banners.values.select{|banner| banner.user.id == user.id}
    end

    def get_count_by_user(user)
      @@banners.select{|id, banner| banner.user.id == user.id}.size
    end
    
  end
end
