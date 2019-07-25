require 'fileutils'

def init_map
  system('ruby --verbose -wW2 -I app -I app/model app/generate_map.rb')
end

def watch_scss
  system('scss --watch front/static/scss/style.scss:front/static/css/style.css')
end

def watch_coffee
  system('coffee -wcm -o front/static/js/ front/static/coffee/*.coffee')
end

task default: [:app]

task :init do
  FileUtils.mkdir_p('front/static/img/bg')
  init_map
  FileUtils.mkdir_p('front/static/css')
  system('scss front/static/scss/style.scss:front/static/css/style.css')
  FileUtils.mkdir_p('front/static/js')
  system('npm install coffeescript')
  system('npm install jquery')
  system('cp node_modules/jquery/dist/jquery.min.js front/static/js/')
  system('cp node_modules/jquery/dist/jquery.min.map front/static/js/')
  system('coffee -c -o front/static/js/ front/static/coffee/*.coffee')
end

task :map do
  init_map
end

task :ws_start do
  system('thin -R ws_config.ru start -C ' + __dir__ + '/config/ws_thin.yml')
end

task :ws_stop do
  system('thin -R ws_config.ru stop -C ' + __dir__ + '/config/ws_thin.yml')
end

task :ws_restart do
  system('thin -R ws_config.ru restart -C ' + __dir__ + '/config/ws_thin.yml')
end

task :css do
  watch_scss
end

task :js do
  watch_coffee
end

task :front_start do
  system('thin -R config.ru start -C ' + __dir__ + '/config/thin.yml --require app/ --require app/model/')
end

task :front_stop do
  system('thin -R config.ru stop -C ' + __dir__ + '/config/thin.yml  --require app/ --require app/model/')
end

task :front_restart do
  system('thin -R config.ru restart -C ' + __dir__ + '/config/thin.yml  --require app/ --require app/model/')
end

task :bots do
  system('ruby app/bot/cell_bot_client.rb')
end

task :orbs do
  system('ruby app/bot/orbs_spawner.rb')
end

task :test do
  system('rspec --format doc')
end

task :test_front do
  system('rspec --format doc --tag js')
end

task :test_fast do
  system('rspec --format doc --tag ~js --tag ~slow')
end
# require 'jasmine'
# load 'jasmine/tasks/jasmine.rake'

# task :jasmine_helpers do
#   system('coffee --watch --bare --no-header -o spec/javascripts/helpers/ spec/javascripts/coffee_helpers/*.coffee')
# end

# task :jasmine_specs do
#   system('coffee --watch --no-header --bare -o spec/javascripts/jasmine_specs/ spec/javascripts/coffee_specs/*.coffee')
# end
