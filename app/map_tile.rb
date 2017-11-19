class MapTile
  attr_accessor :x, :y, :type

  def initialize(x, y, type)
    @x = x
    @y = y
    # type - :grass, :tree, etc
    @type = type
    @title = ''
  end

  def to_hash
    {
      :x => @x,
      :y => @y,
      :title => I18n.t(@type)
    }
  end

  def to_json(generator = JSON.generator)
    to_hash().to_json
  end
end
