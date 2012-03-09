require 'bundler/setup'
Bundler.require

require 'sinatra'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/data-engineering")

# Models
class Revision
  # This class represents each time data is imported
  # It's primary function is to keep track of what data is imported and when
  include DataMapper::Resource

  property :md5, String, :length => 32, :required => true, :key => true
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :customers
  has n, :products
  has n, :merchants

  def self.last_imported
    first(:order => [ :updated_at.desc ])
  end

  # Calculate gross_revenue from this specific revision
  def gross_revenue
    @gross_revenue ||= products.inject(0) { |sum, product| sum += (product.price * product.purchase_count) }
  end
end

class Customer
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  timestamps :at
end

class Product
  include DataMapper::Resource

  property :id, Serial
  property :description, String
  property :price, Decimal
  property :purchase_count, Integer
  timestamps :at
end

class Merchant
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :address, String
  timestamps :at
end

DataMapper.auto_upgrade!

class DataImporter
  require 'csv'

  def self.import(data)
    md5 = Digest::MD5.hexdigest(data.read)                                                             # Calculate md5 sum of data being passed in
    if revision = Revision.get(md5)                                                                    # If this revision exists, this data has already been imported
      revision.touch                                                                                   # Return the Revision object to the controller
    else
      revision = Revision.new(:md5 => md5)                                                             # Instantiate a new Revision
      lines = CSV.read(data, { :col_sep => "\t" })
      lines.shift
      lines.each do |line|
        revision.customers.new(:name => line[0])
        revision.products.new(:description => line[1], :price => line[2], :purchase_count => line[3])
        revision.merchants.new(:name => line[4], :address => line[5])
      end

      revision.save
    end
  end
end

helpers do
  def import_data(data)
    if DataImporter.import(data) && revision = Revision.last_imported
      haml :success, :locals => { :revision => revision }
    else
      haml :failure
    end
  end
end

# Routes/Controllers
get '/' do
  haml :index
end

post '/' do
  if params[:file] && tempfile = params[:file][:tempfile]
    import_data(tempfile)
  else
    haml :index
  end
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

@@success
%h1
  Gross revenue: $#{revision.gross_revenue.to_f}
%p
  %a{:href => '/'} Import another file?

@@failure
%h1 There was a problem importing data.
%p
  %a{:href => '/'} Try again?

