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
        
      - It's hard to tell what's an instance method and what's a class method
        with all the mixin usage...


      

### 0.0.2

* Created some tests
  - Included tests that were in model/nm_datafile_spec.rb

* Fixed bug where fast_decrypt_string_with_pass doesn't implement any kind of password for encryption/ decryption...



### 0.0.1

* Code migrated into this repo
* Pull out the class methods from the class
** 1. Pull all those methods into a module
** 2. Include them on the class where needed.
** 3. Extend them onto the parent namespace module
** 4. Plug the gem into rails and see if it still works.


### 0.0.0

Skeleton
