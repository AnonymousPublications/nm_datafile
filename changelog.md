### TODO:

* Fix the way there's an nm_datafile class... :(
* Define the class methods more clearly...

* Handle $FrontDoorKey
  - When Crypto::clean_decrypt_string is called... it should be called on an instantiation
    that has a symmetric_key set
    - it should also raise an exception if that instance variable isn't set
      - Crypto::clean_decrypt_string is only used from within the gem!
        - data_loading.rb
        - nm_datafile.rb
        
* There's a bug in the BF module I think... the symmetric key is either too short, or doesn't play much of a role in encryption at all
  - It's only accepting keys that are 16 chars long
  - It doesn't matter what the key is...

### 0.1.0

* Fixed bug where fast_decrypt_string_with_pass doesn't implement any kind of password for encryption/ decryption...

How it is used in 0.0.1


How it should be used in 0.1.0


nm_data = NmData.new("this_is_a_key")

nm_data.new_file(file_type, *args)

nm_data.load_binary_data bin_data_string

nm_data.load bin_path



### 0.0.2

* Created some tests
  - Included tests that were in model/nm_datafile_spec.rb




### 0.0.1

* Code migrated into this repo
* Pull out the class methods from the class
** 1. Pull all those methods into a module
** 2. Include them on the class where needed.
** 3. Extend them onto the parent namespace module
** 4. Plug the gem into rails and see if it still works.


### 0.0.0

Skeleton
