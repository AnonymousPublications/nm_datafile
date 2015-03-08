require 'json'
require 'zip'

require 'nm_datafile/version'
require 'nm_datafile/schema'
require 'nm_datafile/b_f'
require 'nm_datafile/data_loading'
require 'nm_datafile/crypto'
require 'nm_datafile/nm_datafile'



module NmDatafile
  # Your code goes here...
  
  # extend Loading
  
  def self.new(file_type, *args)
    NmDatafile.new(file_type, args)
  end

  def self.hello
    puts "hi"
  end
  
end



