require 'rmagick'
require 'fileutils'

require_relative 'app/map'

task default: %w[compile_map]

task :compile_map do
  FileUtils::mkdir_p './img/bg'
  (Map.new).create_canvas_blocks
end
