require 'sinatra/base'

require './user'
require './session'
require './helpers/session_helper'
require './geo_event'
require './helpers/external_apis'

include SessionsHelper

# TODO: figure out sessions/ authenticity token
# TODO: use georss format

# call "rackup -p 4567 -s thin" to run!
class MapSqueak < Sinatra::Base
 
  register Sinatra::Synchrony

  # I had to run sudo -u postgres psql, etc to create user and db
  configure :development do
    # export DATABASE_URL='postgres://ethan:ethan@localhost/mapsqueak'
    set :database, 'postgres://ethan:ethan@localhost/mapsqueak'
  end

  # use ActionDispatch::ParamsParser

  enable :sessions
  # require :login

  get '/' do
    "Mapsqueak"
  end

  get '/squeaks.:format' do 
    params[:max] = params[:num_squeaks]

    @squeak_list = closest_active_geo_events(params) 

    $stderr.puts @squeak_list.inspect

    case params[:format]
    when 'xml'
      # TODO: if the squeak_xml (sent in return from a post command) and this are the same, do a partial with builder.
      builder :squeak_list_xml
    end
  end

  # the format is for the return type. content_type determines how to parse the request
  post '/squeaks.:format' do 

    # TODO either consider action_dispatch to parse the params, thus making consistent with Rails
    # and also do automatic conversions and make json input easier. 
    data = {}
    case request.content_type 
    when 'application/xml'
      data = XmlSimple.xml_in(request.body.read,:forcearray =>false, :keytosymbol=> true,:keeproot => true)
    when 'application/json'
      data = JSON.parse(request.body.read,:symbolize_names => true)
    end

    $stderr.puts data
    @squeak = create_geo_event(data[:squeak].merge({:user_id => current_user.email}))# current_user.email
    
    # TODO: put the facebook token at a different part of the XML? this confuses the ActiveRecord initializer
    squeak_to_facebook(@squeak,data[:squeak][:facebook_token],request.host) if data[:squeak].has_key?(:facebook_token)

    case params[:format]
    when 'xml'
      builder :squeak_xml
    when 'json'
      erb :squeak_json
    end
  end

  get '/squeaks/mine.:format' do
    @squeak_list = user_geo_events(current_user.email,(params[:num_squeaks] || 1000).to_i)
    $stderr.puts @squeak_list.inspect

    $stderr.puts params[:format]
    case params[:format]
    when 'xml'
      # TODO: if the squeak_xml (sent in return from a post command) and this are the same, do a partial with builder.
      builder :squeak_list_xml
    end
  end

  # edit squeak
  put '/squeaks/:id.:format' do 
    "#{params[:id]} #{params[:format]}"
  end

  # TODO: copy any squeak, and assign it to current_user

  # Sessions
  #post '/sessions.:format' do 
    # TODO: parse XML, but for now, this may be depracated
  #end

  post '/sessions' do    
    $stderr.puts params.inspect
    # TODO: abstract away this call?
    # again - straying from the Rails implementation
    user = User.authenticate(params[:email],
			     params[:password])
    
    if user.nil?
      'no such user/password'
    else
      sign_in user
      #TODO: make this more secure by adding HMAC
      $stderr.puts "Signed in #{user.name} #{user.email}"
      'HMAC - coming soon'
    end
  end

  delete '/sessions' do 
    $stderr.puts "Signing out #{current_user.email}"
    sign_out
  end

  # Users 

  # authenticate and make sure we have the correct user
  before '/users/.*' do 
    deny_access unless signed_in?
    
    desired_user = User.find(params[:id])
    unless current_user?(desired_user)
      # TODO: return error
      redirect '/'
      "Access denied"
    end
  end

  # TODO: put this behind SSL 
  post '/users' do 
    # Note we are diverging from the Rails style here
    # user[name]
    # @user = User.new(params[:user])
    @user = User.new(params)
    if @user.save
      $stderr.puts "Signing in #{@user.email}"
      sign_in @user
    else
      'Signup error'
    end
  end

  get '/users/:id.:format' do 

  end
  
  # TODO: put this behind SSL 
  put '/users/:id.:format' do 
    

  end

  delete '/users/:id.:format' do 
    # TODO: don't remove the user, just make them inactive 
  end
end

