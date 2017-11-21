module Transport
  def enterable_for(unit)
    unit.user_id == user_id
  end
end
