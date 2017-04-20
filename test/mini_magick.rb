#/usr/bin/ruby

require 'mini_magick'

MiniMagick::Tool::Montage.new do |builder|
  builder.geometry "+0+0"
  builder << "img/bg_grass_1.png"
  builder << "img/bg_grass_2.png"
  builder << "img/bg_grass_3.png"
  builder << "img/bg_grass_4.png"
  builder << "bg.jpg"
end
