require 'json'
require 'yaml'
require 'zip'

# require 'factory_girl'
# require 'pry'; binding.pry
# require File.expand_path('../../spec/factories/sales.rb', __FILE__)

require 'nm_datafile/version'
require 'nm_datafile/schema'
require 'nm_datafile/b_f'
require 'nm_datafile/data_loading'
require 'nm_datafile/crypto'
require 'nm_datafile/nm_datafile'



module NmDatafile
  FRONT_DOOR_KEY = "$FrontDoorKey"  # Write to NmDatafile::FRONT_DOOR_KEY to set a symetric key
  @@symmetric_key = "$FrontDoorKey"
  
  extend DataLoading
  extend Crypto
  
  def self.new(file_type, *args)
    NmDatafile.new(file_type, *args)
  end
  
  def self.set_symmetric_key(val)
    
  end
  
  
end



