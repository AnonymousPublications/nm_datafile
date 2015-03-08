require 'json'

require "nm_datafile/version"
require "nm_datafile/schema"
require 'nm_datafile/b_f'
require 'nm_datafile/crypto'
require "nm_datafile/nm_datafile"


module NmDatafile
  # Your code goes here...
  
  def self.new(file_type, *args)
    NmDatafile.new(file_type, args)
  end
  
  
end



