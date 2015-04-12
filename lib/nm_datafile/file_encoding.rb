#################
# File Encoding #
#################
require 'zip'
module NmDatafile

  module FileEncoding
    
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
      ::NmDatafile.fast_encrypt_string_with_pass(@front_door_key, string)
    end
    
    # This redirects to the mixin used by Crypto
    # ughhh.....
    def clean_decrypt_string(string)
      ::NmDatafile.clean_decrypt_string(string)
    end
    
  end
end
