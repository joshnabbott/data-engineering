require 'bundler/setup'
Bundler.require

require 'sinatra'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/data-engineering")

# Models
class Customer
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :created_at, DateTime
  property :updated_at, DateTime
end

class Product
  include DataMapper::Resource

  property :id, Serial
  property :description, String
  property :price, String
  property :pruchase_count, Integer
  property :created_at, DateTime
  property :updated_at, DateTime
end

class Merchant
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :address, String
  property :created_at, DateTime
  property :updated_at, DateTime
end

DataMapper.auto_upgrade!

# Routes/Controllers
get '/' do
  haml :index
end

post '/' do
end

__END__

# Views

@@layout
%html
  %head
    %title This is a title
  %body
  = yield

@@index
%form{ :action => '/', :method => :post, :enctype => 'multipart/form-data' }
  %fieldset
    %p
      %label{ :for => "file" } File to import
    %p
      %input{ :type => 'file', :name => "file", :id => "file" }
    %p
      %input{ :type => 'submit', :name => "commit", :value => "Import" }

