require "./front"
require 'sass/plugin/rack'

Sass::Plugin.add_template_location('./scss', './css')
use Sass::Plugin::Rack

run(Cuba)
