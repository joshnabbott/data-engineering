$LOAD_PATH.unshift ::File.expand_path(::File.dirname(__FILE__) + '/lib')

require 'application'

# AUTH for the rest
# use Rack::Auth::Basic, "Restricted Area" do |username, password|
#   [username, password] == ['admin', 'password']
# end

run Rack::URLMap.new("/" => Sinatra::Application)
