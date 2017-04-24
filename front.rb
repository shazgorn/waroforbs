require 'cuba'
require 'cuba/render'
require 'slim'
require 'tilt/sass'

Cuba.plugin Cuba::Render

Cuba.settings[:render][:template_engine] = "slim"

Cuba.define do
  # Drop cache. See Cuba::Render module
  Thread.current[:_cache] = Tilt::Cache.new

  on root do
    render('index', {:body_class => 'main', :title => 'War of Orbs'})
  end

  on get do
    on 'game' do
      render('game', {:body_class => 'game', :title => 'War of Orbs'})
    end

    on 'about' do
      render('about', {:body_class => 'about', :title => 'About War of Orbs'})
    end

    on 'media' do
      render('media', {:body_class => 'media', :title => 'Media, Screenshots'})
    end

    on 'js', extension('js') do |file|
      res['Content-Type'] = 'text/javascript'
      res.write Tilt::CoffeeScriptTemplate.new("./coffee/#{file}.coffee").render
    end

    on 'css' do
      on extension('css') do |file|
        res['Content-Type'] = 'text/css'
        res.write Tilt::ScssTemplate.new("./scss/#{file}.scss").render
      end

      on extension('map') do |file|
        File.open("./css/#{file}.map", 'r') do |f|
          res['Content-Type'] = 'text/plain'
          res.write f.read
        end
      end
    end

    on 'fonts', extension('ttf') do |file|
      File.open("./fonts/#{file}.ttf", 'rb') do |f|
        res['Content-Type'] = 'application/octet-stream'
        res.write f.read
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

  on post do
  end

end
