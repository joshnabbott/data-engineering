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

