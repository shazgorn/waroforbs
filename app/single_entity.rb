module SingleEntity
  def kill
    wound
    false
  end

  def strength
    Config.get(:max_life)
  end
end
