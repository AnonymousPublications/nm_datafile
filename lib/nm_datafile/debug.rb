module NmDatafile

  # Just a (drunken) note about all this stuff... This code, is specific to the rails app AnonymousPublications
  # And is dependant on factory_girl, the factories defined in the rails app, and active record and also
  # the sale model in AnonymousPubliactions.  That sucks (sux), right?  Yes.  
  # To fix it, I should not have a #create_sale method, instead I should create those sales using Factories
  # in the rails app, and then send those records in...  For now, this stuff is just going to sit here though
  module Debug
  
    ###################
    # Testing methods #
    ###################
    
    # do as address_completion_file to create an rfsb that should have already existed, but didn't because a fresh db was used
    # for testing
    def simulate_rfsb_existance_on_webserver
      rfsb = self.ready_for_shipment_batch
      ReadyForShipmentBatch.create(batch_stamp: rfsb["batch_stamp"], sf_integrity_hash: rfsb["integrity_hash"])
    end
    
    # creates an address_completion file based on the contents of the current shippable_file object
    def simulate_address_completion_response(n_shipped, symmetric_key)
      raise "can't make an address_completion_response unless it's a shippable_file" if @file_type != :shippable_file
      setup_object_for_schema   # TODu:  I put this in, there was a bug in the test where it needs to be run... does it not run on init somehow?
      
      shipped_sales = []
      erroneous_addresses = []
      sales.each.with_index do |sale, i|
        if i < n_shipped
          shipped_sales << { "id" => sale["id"] }
        else
          erroneous_addresses << { "id" => sale["id"] }
        end
      end
      
      simulated_response = [shipped_sales, erroneous_addresses, ready_for_shipment_batch]
      config = { file_type: :address_completion_file, symmetric_key: symmetric_key}
      nmd_address_completion = NmDatafile.new(config, *simulated_response)
    end
    
    def generate_upload_params(action = "upload_shippable_file")
      temp_zip = Tempfile.new('temp_zip', "#{Rails.root}/tmp")
      save_to_file(temp_zip.path)
      
      upload_shippable_params = { 
      "file_upload" => { "my_file" => Rack::Test::UploadedFile.new(temp_zip.path, "application/zip") },
      "controller"=>"admin_pages",
      "action"=>action
    }
    end
    
    # Don't use push on #sales, it will use the push on the array.  TODu: to fix this, make the @sales arrays collections
    # and give those collections special properties when push is invoked
    def add_sale(sale)
      # add to collection the sale
      self.sales << sale
      regenerate_rfsb if should_gen_a_new_rfsb?(sale)
    end
    
    # we should NOT make a new rfsb if we're adding an old erroneous sale to the object
    # to check for age... see if it already has an rfsb_id
    def should_gen_a_new_rfsb?(sale)
      return true if sale.ready_for_shipment_batch_id.nil?
      false
    end
    
    def regenerate_rfsb
      rfsb = ReadyForShipmentBatch.gen
      self.ready_for_shipment_batch = rfsb
      rfsb.delete
    end
    
    # create's n valid sales and e erroneous sales
    # Line items are created in this process
    # This is to be run form AnonymousPublications only
    # until it gets 'the big refactor' 
    def create_sales_for_shippable_file(n, e=nil)
      
      if @file_type == :shippable_file
        s, l, a, rfsb = create_sales_and_return_data(n)
        self.sales += s
        self.line_items += l
        self.addresses += a
        self.ready_for_shipment_batch = rfsb
        rfsb.delete
        Sale.deep_delete_sales(s)
      elsif @file_type == :address_completion_file
        s, e, rfsb = create_sales_and_return_data_address_completion_file(n, e)
        self.sales += s
        self.erroneous_sales += e
        
        self.ready_for_shipment_batch = rfsb
        rfsb.delete
        Sale.deep_delete_sales(s)
      end
        
    end
    alias create_sales create_sales_for_shippable_file
    
    
    # puts "Deprecated due to the test being specific to a kind of model and schema"
    def create_sales_and_return_data_address_completion_file(n, e)
      e = 0 if e.nil?
      sales = []
      errors = []
      n.times { sales << FactoryGirl.create(:sale_with_1_book) }
      e.times { errors << FactoryGirl.create(:sale_with_1_book) }
      rfsb = ReadyForShipmentBatch.gen
      
      sales.each {|s| s.ready_for_shipment_batch_id = rfsb.id}
      errors.each {|s| s.ready_for_shipment_batch_id = rfsb.id}
      
      [ sales, errors, rfsb ]
    end
    
    # puts "Deprecated due to the test being specific to a kind of model and schema"
    def create_sales_and_return_data(n)
      sales = []
      n.times { sales << FactoryGirl.create(:sale_with_1_book) }
      rfsb = ReadyForShipmentBatch.gen
      sales.each {|s| s.ready_for_shipment_batch_id = rfsb.id}
      l = capture_line_items(sales)
      a = capture_addresses(sales)
      
      [sales, l, a, rfsb]
    end
    
    def capture_line_items(sales)
      l = []
      sales.each do |s|
        l += s.line_items
      end
      l
    end
    
    def capture_addresses(sales)
      a = []
      sales.each do |s|
        a << s.address
      end
      a
    end
    
    
    
    #################
    # Debug methods #
    #################
    # render a count of sales
    def to_s
      string = "NmDatafile:  \n"
      data_collection_names.each.with_index do |collection_name, i|
        string << "  #{collection_name}: #{@data_collections[i].count}  \n"
      end
      
      data_object_names.each.with_index do |variable_name, i|
        string << "  #{variable_name}: #{1}  \n"
      end
      
      string
    end
    
    def inspect
     puts self.to_s
    end
    
    def ==(other)
      return false if other.class != self.class
      return true if all_data_matches?(other)
      false
    end
    
    def all_data_matches?(other)
      if self.integrity_hash == other.integrity_hash
        if self.build_attributes == other.build_attributes
          return true
        end
      end
      false
    end
  
  end

end
