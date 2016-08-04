class JSONable
  def to_hash
    hash = {}
    self.instance_variables.each do |var|
      hash[var] = self.instance_variable_get var
    end
    hash
  end

  def to_json(generator = JSON.generator)
    to_hash().to_json()
  end
end
