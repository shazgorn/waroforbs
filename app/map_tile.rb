class MapTile
  attr_accessor :x, :y, :type, :path

  def initialize(x, y, type, path)
    @x = x
    @y = y
    # type - :grass, :tree, etc
    @type = type
    @path = path
    @type_title = ''
  end

  def to_hash
    {
      :x => @x,
      :y => @y,
      :type => @type,
      :type_title => I18n.t(@type),
      :path => @path
    }
  end

  def to_json(generator = JSON.generator)
    to_hash().to_json
  end
end
