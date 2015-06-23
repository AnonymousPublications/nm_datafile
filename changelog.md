### TODO:

* Fix the way there's an nm_datafile class... :(
* Define the methods as static methods to make more clear where everything is


### 0.1.0

* Changed the syntax to accept a symmetric_key
* Fixed bug where fast_decrypt_string_with_pass doesn't implement any kind of password for encryption/ decryption...
* Fixed bug in the BF module by replacing it with better code
* Handle $FrontDoorKey



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
