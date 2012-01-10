require 'rubygems'
require 'bundler'
Bundler.setup

# If we break the dependancies up into groups perhaps this will help
#Bundler.require(:default)

require 'active_support'
# require 'action_dispatch' # need actionpack gem for this
require 'sinatra/base'
require 'sinatra/activerecord'
require 'sinatra/synchrony' # note: must use thin for this to work


require './mapsqueak_synchrony'
run MapSqueak
