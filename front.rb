require 'cuba'
require 'cuba/render'
require 'slim'

Cuba.plugin Cuba::Render

Cuba.settings[:render][:template_engine] = "slim"

Cuba.define do

  on root do
    render('index')
  end

  on post do
  end

  on get do
    on 'game' do
      render("game", {:map_height => (9..30)})
    end

    on 'js', extension('js') do |file|
      File.open("./js/#{file}.js", 'r') do |f|
        res['Content-Type'] = 'text/javascript'
        res.write f.read
      end
    end

    on 'css' do
      on extension('css') do |file|
        File.open("./css/#{file}.css", 'r') do |f|
          res['Content-Type'] = 'text/css'
          res.write f.read
        end
      end

      on extension('map') do |file|
        File.open("./css/#{file}.map", 'r') do |f|
          res['Content-Type'] = 'text/plain'
          res.write f.read
        end
      end
    end

    on 'img', extension('png') do |file|
      File.open("./img/#{file}.png", 'rb') do |f|
        res['Content-Type'] = 'image/png'
        res.write f.read
      end
    end

    on 'img/bg', extension('png') do |file|
        File.open("./img/bg/#{file}.png", 'rb') do |f|
          res['Content-Type'] = 'image/png'
          res.write f.read
        end
      end


  end #get
end
