#!/usr/bin/env ruby

require 'gollum/app'
require 'tilt/erb'
require 'active_record'
require 'pg'
require 'bcrypt'

config = YAML.load(File.read('config/database.yml'))
ActiveRecord::Base.configurations["development"] = config["development"]
ActiveRecord::Base.configurations["production"] = config["production"]
ActiveRecord::Base.configurations["test"] = config["test"]
ActiveRecord::Base.establish_connection(:development)
puts ENV["RACK_ENV"]

puts ActiveRecord::Base.configurations

class User < ActiveRecord::Base
  include BCrypt
  def verify_passwd(pwd)
    Password.new(self.crypted_password) == pwd
  end
end


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
    if user = User.find_by(name: params['username']) and user.verify_passwd(params['password'])
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
