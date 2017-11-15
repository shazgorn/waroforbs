module SingleEntity
  def kill
    wound
    false
  end

  def strength
    Config.get('MAX_LIFE')
  end
end
