require "./front"
require 'sass/plugin/rack'
require 'coffee-script'

puts 'sasssss'
Sass::Plugin.add_template_location('./scss', './css')
use Sass::Plugin::Rack

puts 'brewing coffee'
Dir.glob('./coffee/*.coffee').each do |filename|
  base = File.basename(filename, '.coffee')
  puts base
  File.open('./js/' + base + '.js', 'w+') {|f|
    f.write CoffeeScript.compile File.read(filename)
  }
end

run(Cuba)
