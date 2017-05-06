require 'fileutils'
require 'coffee-script'

task default: [:front_restart, :ws_restart]

task :gen_map do
  system('ruby --verbose -wW2 app/ws.rb gen')
end

task ws_restart: [:ws_stop, :ws_start]

task :ws_stop do
  system('ruby --verbose -wW2 app/ws.rb stop')
end

task ws_start: [:ws_stop] do
  system('ruby --verbose -wW2 app/ws.rb')
end

task :css do
  begin
    Dir.mkdir('css')
  rescue SystemCallError
  end
  system('scss scss/style.scss css/style.css')
end

task :js do
  begin
    Dir.mkdir('js')
  rescue SystemCallError
  end
  game_js = ''
  file = File.new('js/game.js', 'w')
  %w[options town_controls controls map units ws app].each do |f|
    puts f
    game_js += CoffeeScript.compile File.read('coffee/' + f + '.coffee')
  end
  file.write game_js
  file.close
  puts 'index'
  File.open('js/index.js', 'w') do |f|
    f.write CoffeeScript.compile File.read('coffee/index.coffee')
  end
end

task front_start: [:js, :css]
       
task :front_start do
  system('thin -R config.ru start -C config/thin.yml')
end

task :front_stop do
  system('thin -R config.ru stop -C config/thin.yml')
end

task front_restart: [:front_stop, :front_start]
