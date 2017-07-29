require 'fileutils'
require 'coffee-script'

task default: [:app]

task :ws_gen_map do
  system('ruby --verbose -wW2 app/ws.rb gen')
end

# task ws_restart: [:ws_stop, :ws_start]

# task :ws_stop do
#   system('ruby --verbose -wW2 app/ws.rb stop')
# end

task :app do
  system('ruby --verbose -wW2 -I app -I app/model app/app.rb')
end

task :css do
  begin
    Dir.mkdir('static/css')
  rescue SystemCallError
  end
  system('sh scss.sh')
end

task :js do
  system('npm install jquery')
  system('cp node_modules/jquery/dist/jquery.min.js static/js/')
  system('cp node_modules/jquery/dist/jquery.min.map static/js/')
  begin
    Dir.mkdir('static/js')
  rescue SystemCallError
  end
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
