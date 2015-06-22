# NmDatafile

NmDatafile is a library that defines a file format that makes adding files and strings to an easy, selfencrypting file that can use either asymetric or symetric cryptography.  

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nm_datafile'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nm_datafile


## Code Example

    nmd = NmDatafile.new(:shippable_file)

    nmd.sales = [1,2,3,4]
    nmd.ready_for_shipment_batch = 1

    nmd.save(path_to_file)

    nmd_loaded = NmDatafile::Load(path_to_file)

    nmd_loaded.sales #=> [1,2,3,4]


## Usage

First define a file Schema.  For instance, if you wanted a file type called 'shippable_file' and you wanted it to have many records of 'sales', 'line_items', etc, 
and you wanted your file to have a string of data named 'ready_for_shipment_batch', then you would define it like so. 

    $nm_datafile_schemas = { 
      schemas: {
        :shippable_file => {
          data_collections: [:sales, :line_items, :discounts, :addresses, :ubws, :encryption_pairs], # name the data that is input into the NMDatafile as an array
          data_objects: [:ready_for_shipment_batch]
        }
      }
    }

First define a schema for your NmDatafile.  For instance, if you wanted a file called 'data_file' and you just wanted a "strings" attribute where you can store an array of encrypted strings, then you could set the below schema.  

    NmDatafile::SCHEMA = {
      schemas: {
        :data_file => {
          data_collections: [:strings], # name the data that is input into the NMDatafile as an array
          data_objects: [:file_owners_name]
        }
      }
    }

That's actually the default schema, so you don't need to set it, it's located in lib/nm_datafile/schema.rb, fyi :)

Now that you've got a schema set up, you can start using your data and easily serialize data into an encrypted file format.  

    nmd = NmDatafile.new(:data_file)
    nmd.strings #=> []
    nmd.strings << "hi"
    nmd.file_owners_name = "dsj"
    nmd.save_to_string # This is a binary string for programmers, you can write it to a file
    nmd.save_to_file('/tmp/file.zip') # this saves your strings to a file
    
Ok, you've done all that, but your data is visible as that it's a zip file.  So to turn sneaky mode on, you'll want to     
    
    NmDatafile.Load('/tmp/secret_file')
    
    
    
# Testing Note

Some cyphers are hardcoded in the tests... so if you make changes to the crypto algo, your tests will fail until you fix this...
    

# TODO

* Finish algo so it uses front door keys... encryption needs to be encrypted with the front door key 
* Make it so the rails app sets up the schema file the proper way
* Specify encryption type in file schema?  (symmetric vs asymmetric)
* Allow exporting data as a stenographic cat.jpg file.  
* Better API for adding a new schema, and better default
* Bring in tests
* Allow PGP to be used to encrypt the file


## Contributing

1. Fork it ( https://github.com/[my-github-username]/nm_datafile/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request



