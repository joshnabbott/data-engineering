class Product
  include DataMapper::Resource

  property :id, Serial
  property :description, String
  property :price, Decimal
  property :purchase_count, Integer
  timestamps :at
end

