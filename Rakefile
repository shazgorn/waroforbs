require 'fileutils'

def init_map
  system('ruby --verbose -wW2 -I app -I app/model app/generate_map.rb')
end

def watch_scss
  system('scss --watch scss/style.scss:static/css/style.css')
end

def watch_coffee
  system('coffee -wcm -o static/js/ coffee/*.coffee')
end

task default: [:app]

task :init do
  FileUtils.mkdir_p('static/img/bg')
  init_map
  FileUtils.mkdir_p('static/css')
  system('scss scss/style.scss:static/css/style.css')
  FileUtils.mkdir_p('static/js')
  system('npm install jquery')
  system('cp node_modules/jquery/dist/jquery.min.js static/js/')
  system('cp node_modules/jquery/dist/jquery.min.map static/js/')
  system('coffee -cm -o static/js/ coffee/*.coffee')
end

task :map do
  init_map
end

task :app do
  system('ruby --verbose -wW2 -I app -I app/model app/app.rb')
end

task :css do
  system('sh scss.sh')
end

task :js do
  system('sh coffee.sh')
end

task :front_start do
  system('thin -R config.ru start -C config/thin.yml')
end

task :front_stop do
  system('thin -R config.ru stop -C config/thin.yml')
end

task front_restart: [:front_stop, :front_start]

task :bots do
  system('ruby app/bot/cell_bot_client.rb')
end

task :orbs do
  system('ruby app/bot/orbs_spawner.rb')
end

task :test do
  # system('ruby -Ilib:test test/minitest/test_log_box.rb')
  # system('ruby -Ilib:test test/minitest/test_unit.rb')
  # system('ruby -Ilib:test test/minitest/test_user.rb')
  # system('ruby -Ilib:test test/minitest/test_game.rb')
  # system('ruby -Ilib:test test/minitest/test_orb_game_server.rb')
  system('bin/rspec --format doc')
end
