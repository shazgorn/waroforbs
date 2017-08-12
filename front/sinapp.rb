# coding: utf-8

require 'sinatra'
require 'i18n'
require 'slim'

I18n.load_path = Dir[File.join(settings.root, 'config/locales/views', '*.yml')]
I18n.default_locale = :ru

set :public_folder, './front/static'

helpers do
  def t(key)
    I18n.t(key)
  end
end

get '/' do
  slim :index, :locals => {:body_class => 'main', :title => t('main_page_title')}
end

get '/game' do
  slim :game, :locals => {:body_class => 'game', :title => t('game_title')}
end
