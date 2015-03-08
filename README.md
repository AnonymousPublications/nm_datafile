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

First define a file Schema.  
For instance, if you wanted a file type called 'shippable_file' and you wanted it to have many records of 'sales', 'line_items', etc, 
and you wanted your file to have a string of data named 'ready_for_shipment_batch', then you would define it like so. 

    $nm_datafile_schemas = { 
      schemas: {
        :shippable_file => {
          data_collections: [:sales, :line_items, :discounts, :addresses, :ubws, :encryption_pairs], # name the data that is input into the NMDatafile as an array
          data_objects: [:ready_for_shipment_batch]
        }
      }
    }

TODO:  Specify encryption type on file as well...

Then you'd want to create the NMD file:

And finally save it as shown below:


## Contributing

1. Fork it ( https://github.com/[my-github-username]/nm_datafile/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request



