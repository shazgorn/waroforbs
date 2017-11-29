module MapHelper
  ##
  # max distance by any axis

  def max_diff(x1, y1, x2, y2)
    [(x1 - x2).abs(), (y1 - y2).abs()].max
  end
end
