class Merchant
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :address, String
  timestamps :at
end

