require 'bundler/setup'
Bundler.require

require 'sinatra'

# Setup DB
DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/data-engineering")

# Load models
Dir[File.dirname(__FILE__) + "/models/*.rb"].each { |file| require file }

# Run "migrations"
DataMapper.auto_upgrade!

# Load anything else we're gonna need from the lib directory
require 'data_importer'

helpers do
  def import_data(data)
    begin
      if DataImporter.import(data) && revision = Revision.last_imported
        haml :success, :locals => { :revision => revision }
      else
        haml :failure
      end
    rescue Exception => e
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
    %title Data-Engineering Example
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
  Gross revenue from this import - $#{revision.gross_revenue.to_f}
%p
  %a{:href => '/'} Import another file?

@@failure
%h1 There was a problem importing the data.
%p Please make sure:
%ul
  %li You are uploding a tab-delimited file
  %li The data in the file is properly formatted
  %li You have had enough coffee today
%p
  %a{:href => '/'} Try again?

