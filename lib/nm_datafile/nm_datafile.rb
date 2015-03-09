module NmDatafile

  # This class describes a way for AP to convert data into a portable format 
  # (zip_file.nmd).  nms == aNonyMousDatafile 
  #
  #   To create a new file, you first must define a schema.  As of right now, 
  # there are two public schemas.  As defined in these schemas, NmDatafiles 
  # consist of collections of objects, and individual objects... eg
  # An instance might have nmd.important_numbers which is an array of number, 
  # whereas it might also have a data_object, nmd#stupidest_number which is a
  # single number.  
  #
  #   So to create an NmDatafile, do
  # `NmDatafile.new(:shippable_file, sales, line_items, addresses, rfsb)`
  # that will work if you have a schema that has 3 data_collections specified
  # and 1 data_object specified in the schema named :shippable_file.  
  #
  #   Using NmDatafiles allows you access to utility functions such as
  #     - #save_to_string
  #     - #save_to_file
  #     - tons of testing methods
  #
  #   The NmDatafile is just a zip, but it's a password protected zip, and 
  # it can also be obfuscated to confuse the feds.  
  #
  # Creating a new APDatafile means creates, in memory, a way to:
  #  - Render the data to the hdd as a zip file
  #  - Render the data as a string which can be streamed as a zip file
  #  - Reading a file
  #  - Encrypt the data (assymetrically?) YES
  #  - Define the standard for formating 
  #  - Create mock data outputs easily (helpful in testing)
  #  - Specify the version of the file
  #  - File can non-destructively corrupt itself so it doesn't look so much like a zip file to cryptographic analists
  #  - Object is responsive to what ever schema it's set to... so it will be able to do
  #       shippable_file = NmDatafile.new(:shippable_file);  shippable_file.sales << Sale.new
  #  - loads data, nmd.load_data([sales, line_items, addresses, [ready_for_shipment_batch]])
  #  - loads variables nmd.load_data([sales, line_items, addresses, ready_for_shipment_batch])

  # Encrypt the data (asymetrically?) YES
  #   To do this, all the files should be lumped together as one huge string (a hash of file names and data strings)... split by a special split marker and file name definer such as
  #   Data Encryption:
  #     Meth. 1)  Once this massive string is created, a PGP key is used to encrypt the whole file.  
  #     Meth. 2)  The data can be encrypted using a randomly generated password, and then the password get's encrypted with PGP <- better
  #
  #   

  # (r)  file_type:  Can be 
  #      - shippable_file, used to export shipping data from AP book shopping app
  #      - address_completion_file, used to transfer data from shipping machine to AP book shopping app
  #      - db_backup_file, used to download a complete backup of a webserver
  #      - etc, etc, used for other organization objectives
  #
  # (w)  set_public_key:  Specify a public PGP key to encode the data with
  #
  # (r)  get_public_key:  Shows the email and fingerprint of the key that's been set (for debugging)
  # 
  # (r)  show_current_schema:  Shows the data schema for the file type
  # 
  # (w)  set_current_schema:   deletes all data and sets the schema
  #
  # (r)  save_to_string:  creates the zip file, handleing
  #
  # (rw) protected: bool, specifies whether the file is secured with PGP or if it's just a zip file
  #
  # (m)  Load: loads a file into memory as an NmDatafile
  #
  # (m)  load_data:  loads array of data into memory as an NmDatafile object


  # PRIVATE
  # (m)  encrypt_file!:  Does all encryption procedures before rendering to a string or file
  #
  # (m)  decrypt_file!:  reverse of encrypt_file!
  #
  # (m)  encrypt_string:  symetrically encrypts a string using a password
  #
  # (m)  decrypt_string:  reverse of encrypt_string
  # 
  # (m)  encrypt_symetric_key:  uses PGP to encrypt the password that encrypted the data
  #
  # (m)  decrypt_symetric_key:  reverse of encrypt_symetric_key.
  #
  # (m)  corrupt_zip:  corrupts the zip file so it doesn't look like a zip file, make it look like a jpeg
  #
  # (m)  uncorrupt_zip:  reverses corrupt_zip file so the zip can be processed
  # 
  # (m)  
  # aNonyMousDatafile
  class NmDatafile
    @@schemas = ::NmDatafile::SCHEMA[:schemas]  # TODO:  move to initialize
    @@clear_text_path = "clear_text_protected_nmd" # used for using system calls to decrypt and encrypt using a zip password
    attr_reader :file_type, :password
    
    # include Crypto
    
    
    
    
    ###############################
    # Loading and Dumping Methods #
    ###############################
    
    # notice migration to loading.rb
    
    def initialize(file_type, *args)
      set_file_type(file_type)
      
      load_data(args)
      
      setup_object_for_schema
    end
    
    def load_attributes(attribute_data)
      d = YAML::load attribute_data
      @file_type = d["file_type"].to_sym
      @build_date = Time.zone.parse d["build_date"] unless d["build_date"].nil?
    end
    
    def load_encryption(encryption_data)
      d = YAML::load encryption_data
      @integrity_hash = d["integrity_hash"] unless d["integrity_hash"].nil?
      @password = clean_decrypt_string(d["password"]) unless d["password"].nil?
    end
    
    # (m)  load_data:  loads array of data into memory as an NmDatafile object
    # clears the data arrays so it's like reinitializing the whole file
    def load_data(*args)
      init_data_arrays  # wipes all preexisting data in @data_collections and @data_objects
      
      args[0].each.with_index do |array_or_variable, i|
        if i < data_collection_names.count
          @data_collections[i] += array_or_variable 
        else
         j = i - data_collection_names.count
         @data_objects[j] = array_or_variable #  if array_or_variable.class != Array
        end
      end
      self
    end
    
    
    def save_to_string
      set_password
      
      clear_text = build_encryptable_portion
      encrypted_data = encode_string_as_password_protected(clear_text)
      
      hash_of_entries = { :crypt => encrypted_data,
                          :encryption => build_encryption,
                          :attributes => build_attributes }
      
      encode_datafiles_as_zip(hash_of_entries)
    end
    
    def save_to_file(path)
      File.write(path, save_to_string)
    end
    
    def set_password
      len = 41
      
      password = ""
      chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a + ['!', '@', '#', '$', '%', '^', '&', '*', '(', ')']
      
      1.upto(len) { |i| password << chars[rand(chars.size-1)]}
      
      space = rand(len-1)
      password[space] = ("0".."9").to_a[rand(9)]  # ensure there's number and letter
      space += 1
      space = 0 if space == len
      password[space] = ("a".."z").to_a[rand(22)]
      
      @password = password
    end
    
    # TODO del me
    def version
      "0.0.0"
    end
    
    def integrity_hash
      encryptable_portion = build_encryptable_portion
      Digest::SHA2.hexdigest(encryptable_portion)
    end
    
    def build_data_collections
      @data_collections.to_json
    end
    
    def build_data_objects
      @data_objects.to_json
    end
    
    def build_attributes
      hash = { file_type: @file_type
                # build_date: Time.zone.now,           # TODu:  change me to the date the data was last modified...
              }.to_json
    end
    
    def build_encryption
      hash = { integrity_hash: integrity_hash,
               password: clean_encrypt_string(@password)
             }.to_json
    end
    
    def build_encryptable_portion
      e = { :data_collections => @data_collections,
        :data_objects => @data_objects
      }.to_json
    end
    
    
    
    #######################
    # schema related junk #
    #######################
    
    def schema
      @@schemas[@file_type]
    end
    
    def data_collection_names
      schema[:data_collections]
    end
    
    def data_object_names
      schema[:data_objects]
    end
    
    def var_names
      data_collection_names + data_object_names
    end
    
    # specify the schema type
    def set_file_type(file_type)
      @file_type = file_type
      init_data_arrays
    end
    
    def init_data_arrays
      @data_collections = []
      data_collection_names.count.times { @data_collections << [] }
      @data_objects = []
      data_object_names.count.times { @data_objects << [] }
    end
    
    # This makes it so you can call file.attribute to get direct access to an attribute
    def setup_object_for_schema
      data_collection_names.each.with_index do |data_collection_name, i|
        # define getter
        self.define_singleton_method(var_names[i]) do
          @data_collections[i]
        end
        # define setter
        self.define_singleton_method((data_collection_names[i].to_s + "=").to_sym) do |val|
          @data_collections[i] = val
        end
      end
      
      data_object_names.each.with_index do |data_object_name, i|
        # getters
        self.define_singleton_method(data_object_name) do
          @data_objects[i]
        end
        # setters
        self.define_singleton_method((data_object_name.to_s + "=").to_sym) do |val|
          @data_objects[i] = val
        end
      end
      
    end
    
    
    
    
    # This method get's the temp directory.  If it's a rails
    # app, that would be Rails.root/tmp, else just /tmp
    def get_temp_directory
      defined?(Rails) ? "#{Rails.root}/tmp" : "/tmp"
    end
    
    ###############
    # zip methods #
    ###############
    require 'zip'
    
    # hash consists of {file1: string_data}
    # output is a binary string representing a zip file of the entries specified
    def encode_datafiles_as_zip(hash_of_entries)
      temp_file = Tempfile.new(file_type.to_s, get_temp_directory)
      FileUtils.rm temp_file.path
      
      stream = ::Zip::OutputStream.write_buffer do |zos|
        hash_of_entries.each do |entry_name, data|
          zos.put_next_entry entry_name
          zos.write data
        end
      end
      
      stream.rewind
      stream.read
    end
    
    
    
    # Play:
    # Below will write to stdout as long as stdout isn't the terminal (so works in irb and ruby)
    # zip -P 'fp5!IZbVxgx2hWh8m*UQyc@d5nCGCrbiqPx73hh&' - file_to_add
    #
    # Below is attempt to read file from stdin:
    # out = `echo 'hi' | zip -P 'fp5!IZbVxgx2hWh8m*UQyc@d5nCGCrbiqPx73hh&' - -`
    #
    #
    # Zip commandline is
    # zip -P 'fp5!IZbVxgx2hWh8m*UQyc@d5nCGCrbiqPx73hh&' zip_to_make.zip file_to_add
    # maybe password has invalid chars
    def encode_string_as_password_protected_old_zip_based(encryptable_portion, pass = nil)
      pish = @password 
      pish = pass unless pass.nil?
      
      supress_errors = "2>/dev/null"
      # this will read that file... let's try passing it in from stdin pipes though
      # alt = "zip -P '#{pish}' - #{@@clear_text_path}"
      
      # TODu:  escape single quotes or this command breaks...  
      raise "tried to encrypt an encryptable_portion which contained illegal character ' which would break the command being piped to zip" if encryptable_portion =~ /\'/ 
      # passing in clear_text through pipes
      alt = "echo '#{encryptable_portion}'| zip -P '#{pish}' - - #{supress_errors}"
      #alt = "echo '#{encryptable_portion.gsub("\\n", "")}'| zip -P '#{pish}' - -"

      binary_output = `#{alt}`
    end
    
    
    
    
    def encode_string_as_password_protected(encryptable_portion, pass = nil)
      #require 'b_f'
      
      pish = @password
      pish = pass unless pass.nil?
      raise "error, password given was too long, must be 56 or less chars" if pish.length > 56
      
      bf = BF.new(pish, true)
      
      encrypted = bf.encrypt(encryptable_portion)
    end
    
    
    def decode_password_protected_string(password, decryptable_portion)
      ::NmDatafile.decode_password_protected_string(password, decryptable_portion)
    end
    
    def obfuscate_file_format
      # TODu: implement me
    end
    
    def deobfuscate_file_format
      
    end
    
    
    def clean_encrypt_string(string)
      # Base64.encode64(encode_string_as_password_protected(string, @@unsecure_pass))
      ::NmDatafile.fast_encrypt_string_with_pass(::NmDatafile::FRONT_DOOR_KEY, string)
    end
    
    # Crypto
    def clean_decrypt_string(string)
      ::NmDatafile.clean_decrypt_string(string)
    end
    
    
    
    
    
    
    # `gpg -c --no-use-agent`
    
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
    def simulate_address_completion_response(n_shipped)
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
      
      nmd_address_completion = NmDatafile.new(:address_completion_file, *simulated_response)
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
    
    # create's some sales, line_items and 
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
    
    #####################################################
    #  batch checking, high conasence with Importable   #
    #####################################################
    
    # Move to... NmDatafile
    def duplicate_batch?(previous_batch)
      return false if previous_batch.nil?
      
      previous_batch.sf_integrity_hash == integrity_hash
    end
    
    
  end


  # Zip Entry Structure
  # data_collections:  array of data collections... atm, contains
  # data_objects:      array of data_objects
  # schema:            Schema of the data...  this should be encrypted if data1 is encrypted
  # encryption:  integrity_hash: SHA2 hash of data for fingerprinting, password: password used to encrypt the data entrys
  # attributes: - @file_type, nmd_version, build_date, PGP key id used for encrypting the encryption entry

  # Zip Entry Structure after full protection
  # crypt (encrypted: data_collections, data_objects, schema)
  # encryption (encrypted)
  # attributes (clear_text)

  
  # This hack is for... some tricky bullshit, I forgot about
  def passfunc(hook, uid_hint, passphrase_info, prev_was_bad, fd)
    $stderr.write("Passphrase for #{uid_hint}: ")
    $stderr.flush
    begin
      system('stty -echo')
      io = IO.for_fd(fd, 'w')
      io.puts(gets)
      io.flush
    ensure
      (0 ... $_.length).each do |i| $_[i] = ?0 end if $_
      system('stty echo')
    end
    $stderr.puts
  end
  
  
end




