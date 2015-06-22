module NmDatafile
  
  module DataLoading
    
    # (m)  Load: loads a file into memory as an NmDatafile
    # TODO: Make lowercase
    def Load(file_path)
      zip_data = File.read(file_path)
      load_binary_data(zip_data)
    end
    
    # TODO: Make lowercase
    def load_binary_data(binary_data)
      hash = extract_entities_from_binary_data(binary_data)
      
      file_type = determine_file_type(hash[:attributes])
      nmd = NmDatafile.new( file_type )
      
      nmd.load_attributes(hash[:attributes]) unless hash[:attributes].nil?
      nmd.load_encryption(hash[:encryption])
      
      nmd.load_data([*hash[:data_collections], *hash[:data_objects]])
    end
    
    def determine_file_type(attributes_hash)
      attributes_hash = YAML::load attributes_hash
      attributes_hash["file_type"].to_sym
    end
    
    
    def determine_password(hash)
      d = YAML::load hash[:encryption]
      ::NmDatafile.clean_decrypt_string(d["password"])
    end
    
    # This method peers through a zip binary data blob and returns a hash consisting of
    # { file_name1: file_data1, etc }
    def extract_entities_from_binary_data(binary_data)
      binary_data_io = StringIO.new(binary_data)
      
      hash = {}
      ::Zip::InputStream.open(binary_data_io) do |io|
        while (entry = io.get_next_entry)
          hash[entry.name.to_sym] = io.read
        end
      end
      
      password = self.determine_password(hash)
      
      decrypt_encryptable_data!(password, hash)
      hash
    end
    
  end
  
end
