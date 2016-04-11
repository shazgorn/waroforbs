require "./front"
require 'sass/plugin/rack'
require 'coffee-script'

system 'sh compile.sh'

run(Cuba)
