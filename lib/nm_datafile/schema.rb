# A default schema is defined here... this needs to be converted into 
# something more generic
module NmDatafile
  SCHEMA = { schemas: 
                         { :shippable_file => {
                           data_collections: [:sales, :line_items, :discounts, :addresses, :ubws, :encryption_pairs], # name the data that is input into the NMDatafile as an array
                           data_objects: [:ready_for_shipment_batch]
                           },
                         
                         :address_completion_file => {
                           data_collections: [:sales, :erroneous_sales],
                           data_objects: [:ready_for_shipment_batch]
                           }
                         }
                       }
end
