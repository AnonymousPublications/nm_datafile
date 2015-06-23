require 'nm_datafile/debug'
require 'nm_datafile/file_encoding'

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
    @@clear_text_path = "clear_text_protected_nmd" # used for using system calls to decrypt and encrypt using a zip password
    
    attr_reader :file_type, :password, :symmetric_key
    attr_accessor :schemas
    
    # include Crypto
    include Debug
    include FileEncoding
    include Crypto
    
    ###############################
    # Loading and Dumping Methods #
    ###############################
    
    # notice migration to loading.rb
    
    def initialize(config, *args)
      file_type = config[:file_type]
      @symmetric_key = config[:symmetric_key]
      @schemas = ::NmDatafile::SCHEMA[:schemas]
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
      @password = ::NmDatafile.clean_decrypt_string(d["password"], @symmetric_key) unless d["password"].nil?
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
                # build_date: Time.zone.now,           # TODO:  change me to the date the data was last modified...
              }.to_json
    end
    
    def build_encryption
      hash = { integrity_hash: integrity_hash,
               password: clean_encrypt_string(@password, @symmetric_key)
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
      @schemas[@file_type]
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
    
    
    
    
    
    
    # `gpg -c --no-use-agent`
    
    
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




