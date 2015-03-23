require 'spec_helper'

describe "nm_datafile" do

  before :each do
    #@sample_data = get_sample_data
    @sales = [{"address_id"=>1, "created_at"=>"2015-03-08T03:54:51Z", "currency_used"=>"BTC"}]
    @sample_data = [ @sales ]
    @binary_nmd_path = 'spec/data/nmd_binary_string_w_2s_2li_2a_1ubws_1ep.zip'
  end
  
  it "should be able to load data from a binary string" do
    nmd_binary_string = File.read(@binary_nmd_path)
    
    nmd_file = NmDatafile::LoadBinaryData nmd_binary_string
    
    sales = nmd_file.sales
    line_items = nmd_file.line_items
    discounts = nmd_file.discounts
    addresses = nmd_file.addresses
    ubws = nmd_file.ubws
    encryption_pairs = nmd_file.encryption_pairs
    rfsb = nmd_file.ready_for_shipment_batch
    
    nm_data = NmDatafile.new(:shippable_file, sales, line_items, discounts, addresses, ubws, encryption_pairs, rfsb)
    
    nm_data.sales.count.should eq 2
    nm_data.ready_for_shipment_batch["batch_stamp"].should eq rfsb["batch_stamp"]
  end

  it "should be able to load data from a path to a zip" do
    
    nmd_string_loaded = NmDatafile::LoadBinaryData File.read(@binary_nmd_path)
    
    nmd_path_loaded = NmDatafile::Load @binary_nmd_path
    
    nmd_string_loaded.sales.should eq nmd_path_loaded.sales
  end

  it "should be able to save data as a zip string" do
    nmd_shippable = NmDatafile.new(:shippable_file, *@sample_data)
    
    nmd = NmDatafile::LoadBinaryData nmd_shippable.save_to_string
    
    nmd.sales.should eq @sample_data.first
  end
  
  it "should be able to load in the attributes" do
    nmd = NmDatafile::Load @binary_nmd_path
    
    nmd.file_type.should eq :shippable_file
  end


end


