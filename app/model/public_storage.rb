module PublicStorage
  def to_enemy_hash
    hash = super
    hash.merge!({
                  :inventory => @inventory
                })
  end
end
