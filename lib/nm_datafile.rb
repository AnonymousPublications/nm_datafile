require 'json'
require 'yaml'
require 'zip'

# require 'factory_girl'
# require 'pry';
# require File.expand_path('../../spec/factories/sales.rb', __FILE__)

require 'nm_datafile/version'
require 'nm_datafile/schema'
require 'nm_datafile/b_f'
require 'nm_datafile/data_loading'
require 'nm_datafile/crypto'
require 'nm_datafile/nm_datafile'


module NmDatafile
  FRONT_DOOR_KEY = "this_is_a_keythis_is_a_keythis_is_a_keythis_is_a_key"
  
  extend DataLoading
  extend Crypto
  extend FileEncoding
  
  # The symmetric_key is the key that encrypts the key that encrypts the data...
  def self.new(config, *args)
    #config = {file_type: file_type, symmetric_key: FRONT_DOOR_KEY}
    NmDatafile.new(config, *args)
  end
  
  def self.set_symmetric_key(val)
    $FrontDoorKey = val
  end
  
  def self.front_door_key
    @@front_door_key
  end
  
  def self.front_door_key=(v)
    @@front_door_key = v
  end
  
end



