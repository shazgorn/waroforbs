require 'fileutils'
require 'coffee-script'

task default: [:front_restart, :ws_restart]

task :ws_gen_map do
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
  system('sh scss.sh')
end

task :js do
  begin
    Dir.mkdir('js')
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
