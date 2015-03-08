module NmDatafile
  
  module DataLoading
    # (m)  Load: loads a file into memory as an NmDatafile
    # TODO: Make lowercase
    def Load(file_path)
      zip_data = File.read(file_path)
      LoadBinaryData(zip_data)
    end
    
    # TODO: Make lowercase
    def LoadBinaryData(binary_data)
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
      clean_decrypt_string(d["password"])
    end
    
  end
  
end
