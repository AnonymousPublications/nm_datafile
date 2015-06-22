# https://gist.github.com/nono/2995118

require "openssl"
require "base64"

module NmDatafile

  class BF < Struct.new(:key, :pad_with_spaces)
    def encrypt(str)
      str = Base64.encode64(str)
      cipher = OpenSSL::Cipher.new('bf-ecb').encrypt
      if pad_with_spaces
        str += " " until str.bytesize % 8 == 0
        cipher.padding = 0
      end
      cipher.key = key
      binary_data = cipher.update(str) << cipher.final
      hex_encoded = binary_data.unpack('H*').first
    end
     
    def decrypt(hex_encoded)
      cipher = OpenSSL::Cipher.new('bf-ecb').decrypt
      cipher.padding = 0 if pad_with_spaces
      cipher.key = key
      binary_data = [hex_encoded].pack('H*')
      str = cipher.update(binary_data) << cipher.final
      str.force_encoding(Encoding::UTF_8)
      str = Base64.decode64(str.strip)
      str
    end
  end

end



