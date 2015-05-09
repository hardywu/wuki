#!/usr/bin/env ruby

require 'gollum/app'
require 'tilt/erb'
require 'active_record'
require 'pg'

date_config = YAML.load(File.read('config/database.yml'))
ActiveRecord::Base.configurations["development"] = date_config["development"]
ActiveRecord::Base.configurations["production"] = date_config["production"]
ActiveRecord::Base.configurations["test"] = date_config["test"]
ActiveRecord::Base.establish_connection ENV["RACK_ENV"].to_sym

puts ActiveRecord::Base.configurations

require "./model/user.rb"

gollum_path = File.expand_path(File.dirname(__FILE__) + '/wiki.git') # CHANGE THIS TO POINT TO YOUR OWN WIKI REPO
Precious::App.set(:gollum_path, gollum_path)
Precious::App.set(:default_markup, :markdown) # set your favorite markup language
Precious::App.set(:wiki_options, {
		:universal_toc => true,
		:mathjax => true
	})

class Wuki < Sinatra::Base
  enable :sessions
  before do
    pass if request.path_info.split('/')[1] == 'auth'
    if !session['user']
      redirect '/auth/login'
    end
  end

  get '/auth/login' do
    erb :login
  end

  post '/auth/login' do
    puts params
    if user = User.find_by(email: params['email']) and user.has_password?(params['password'])
      session['user'] = user
      redirect '/'
    else
      redirect '/auth/login'
    end
  end

  delete '/auth/logout' do
    session['user'] = nil
    redirect '/'
  end

  get '/auth/logout' do
    session['user'] = nil
    redirect '/'
  end
end

module Myapp
  def self.registered(app)
    app.use Wuki
  end
end

Precious::App.register Myapp
# Precious::App.register Omnigollum::Sinatra
run Precious::App
