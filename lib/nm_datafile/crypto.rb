require 'base64'

module NmDatafile

  module Crypto
    # The zip implementation... should use 7z though and throw this out when it's done... or truecript or gpg...
    def decode_protected_zip_old_zip_based(password, decryptable_portion)
      encryptable_portion = Tempfile.new('encryptable_portion', "#{Rails.root}/tmp")
      FileUtils.rm(encryptable_portion.path)
      File.binwrite(encryptable_portion.path, decryptable_portion)
      
      supress_errors = "2>/dev/null"
      decompress_zip_cmd = "funzip -'#{password}' '#{encryptable_portion.path}' #{supress_errors}"

      clear_text_hash = `#{decompress_zip_cmd}`.chomp
      
      clear_text_hash = convert_newline_chars_back_to_symbols(clear_text_hash)
      
      FileUtils.rm(encryptable_portion.path)
      clear_text_hash
    end
    
    # TODu:  rename to decode_string_as_password_protected
    def decode_string_as_password_protected(password, decryptable_portion)
      #require 'b_f'
      bf = BF.new(password, true)
      
      bf.decrypt(decryptable_portion)
    end
    
    
    # Takes in a password and binary data of protected archive file and outputs
    # a string of it's first entry in clear text which should be a hash
    # of {:file_name, "file_data"}
    def decode_password_protected_string(password, decryptable_portion)
      decode = decode_string_as_password_protected(password, decryptable_portion)
    end
    
    
    
    # converts the string pairs into symbol/ string pairs
    def symbolize_keys(decode)
      p = {}
      decode.each do |key_pair|
        p.merge!( { key_pair[0].to_sym => key_pair[1] } )
      end
      p
    end
    
    
    
    
    def convert_newline_chars_back_to_symbols(clear_text_hash)
      clear_text_hash.gsub("\n", "\\n")
    end
    
    # I think 7z is considered secure and zip is considered insecure so write this
    def decode_protected_7z(password, decryptable_portion)
      # TODu: implement
    end
    
    
    def decrypt_encryptable_data!(password, hash)
      return if hash[:crypt].nil?  # leave this function if there's no 'crypt' entry to decrypt
      
      decode = decode_string_into_NMDatafile_stores(password, hash[:crypt])
      
      hash.delete :crypt
      
      hash.merge!(decode)
    end
    
    def decode_string_into_NMDatafile_stores(password, crypt_string)
      decode = YAML::load decode_password_protected_string(password, crypt_string)
      decode = symbolize_keys(decode)
    end
    
    
    
    def clean_decrypt_string(string)
    #  string = Base64.decode64 string
    #  decode_password_protected_string(@@unsecure_pass, string)
      NMDatafile.fast_decrypt_string_with_pass(@@unsecure_pass, string)
    end
    
    
    
    def fast_encrypt_string_with_pass(pass, string)
      encoded_as_base64 = Base64.encode64(string)
      rearranged = rearrangement(encoded_as_base64)
      obfs = obfuscated_ending(rearranged)
      Base64.encode64(obfs)
    end
    
    def fast_decrypt_string_with_pass(pass, string)
      obfs = Base64.decode64(string)
      rearranged = obfuscated_ending_undo(obfs)
      encoded_as_base64 = rearrangement_undo(rearranged)
      Base64.decode64(encoded_as_base64)
    end
    
    def rearrangement(s)
      s = the_last_three_chars(s) + the_string_minus_the_last_three_chars(s)
    end
    
    def rearrangement_undo(s)
      s = the_string_minus_the_first_three_chars(s) + the_first_three_chars(s)
    end
    
    
    def obfuscated_ending(s)
      junk = "tlD3=\n"
      s + junk
    end
    
    def obfuscated_ending_undo(s)
      junk = "tlD3=\n"
      s[0...(-1*junk.length)]
    end
    
    # hide these somewhere, so ugly
    def the_last_three_chars(s)
      s[-3..-1]
    end
    
    def the_first_three_chars(s)
      s[0..3]
    end
    
    def the_string_minus_the_last_three_chars(s)
      s[0...-3]
    end
    
    def the_string_minus_the_first_three_chars(s)
      s[2..-1]
    end
    
    
    def encrypt_using_gpg(pass, string)
      crypto = GPGME::Crypto.new :symmetric => true, :password => "gpgme"
      encrypted_data = crypto.encrypt "string"
      encrypted_data.read
    end
  end

end
