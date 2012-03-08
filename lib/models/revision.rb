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

