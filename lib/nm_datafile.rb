require 'json'
require 'yaml'
require 'zip'

require 'nm_datafile/version'
require 'nm_datafile/schema'
require 'nm_datafile/blowfish'
require 'nm_datafile/data_loading'
require 'nm_datafile/crypto'
require 'nm_datafile/nm_datafile'


module NmDatafile
  extend DataLoading
  extend Crypto
  extend FileEncoding
  
  #config = {file_type: file_type, symmetric_key: symmetric_key}
  def self.new(config, *args)
    NmDatafile.new(config, *args)
  end
  
end



