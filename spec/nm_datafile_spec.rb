require 'spec_helper'

describe "nm_datafile" do

  before :each do
    #@sample_data = get_sample_data
    @sale = {"address_id"=>1, "created_at"=>"2015-03-08T03:54:51Z", "currency_used"=>"BTC"}
    @sample_data = [ @sale ]
  end
  

  it "should be instantiable" do
    NmDatafile.new(:shippable_file)
  end


  it "should be instantiable with data" do
    #return_array = [ @sales, 
    #                 @line_items, 
    #                 @discounts,
    #                 @addresses, 
    #                 @utilized_bitcoin_wallets,
    #                 @encryption_pairs,
    #                 rfsb ]
    
    nmd_shippable = NmDatafile.new(:shippable_file, *@sample_data)
    
    str = nmd_shippable.save_to_string
    
    binding.pry
    
  end

end


