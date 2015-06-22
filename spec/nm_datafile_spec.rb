require 'spec_helper'

describe "nm_datafile" do

  before :each do
    #@sample_data = get_sample_data
    @sales = [{"address_id"=>1, "created_at"=>"2015-03-08T03:54:51Z", "currency_used"=>"BTC"}]
    @sample_data = [ @sales ]
    # binary_nmd_info:
    #     decrypted password should be: "@(OfMLpCe@pV(GGLuEvj(Tup$BaFodP3!6^5%5pTW"
    # 
    # if you change the encryption algo, recreate this file with the help of the first test
    @binary_nmd_path = 'spec/data/nmd_binary_string_w_2s_2li_2a_1ubws_1ep.zip' 
  end
  
  it "should be able to create an nmd_file out of complicated data hashes and save it" do
    sales = [{"address_id"=>1, "created_at"=>"2015-03-23T01:55:04Z", "currency_used"=>"BTC", "delivery_acknowledged"=>nil, "id"=>1, "original_id"=>nil, "prepped"=>true, "ready_for_shipment_batch_id"=>1, "receipt_confirmed"=>"2015-03-23T01:55:04Z", "sale_amount"=>"4500000.0", "shipped"=>nil, "shipping_amount"=>0.0, "total_amount"=>"4500000.0", "updated_at"=>"2015-03-23T01:55:04Z", "user_id"=>1, "utilized_bitcoin_wallet_id"=>1}, {"address_id"=>5, "created_at"=>"2015-03-23T01:55:04Z", "currency_used"=>"BTC", "delivery_acknowledged"=>nil, "id"=>2, "original_id"=>nil, "prepped"=>true, "ready_for_shipment_batch_id"=>1, "receipt_confirmed"=>"2015-03-23T01:55:04Z", "sale_amount"=>"4500000.0", "shipped"=>nil, "shipping_amount"=>0.0, "total_amount"=>"4500000.0", "updated_at"=>"2015-03-23T01:55:04Z", "user_id"=>2, "utilized_bitcoin_wallet_id"=>1}]
    line_items = [{"created_at"=>"2015-03-23T01:55:04Z", "currency_used"=>"BTC", "description"=>nil, "discount"=>nil, "discounted_amount"=>nil, "discounted_item_id"=>nil, "id"=>1, "original_id"=>nil, "price"=>"4500000.0", "price_after_product_discounts"=>nil, "price_extend"=>"4500000.0", "product_sku"=>"0001", "qty"=>1, "sale_id"=>1, "shipping_cost"=>"0.0", "shipping_cost_btc"=>0, "shipping_cost_usd"=>"0.0", "updated_at"=>"2015-03-23T01:55:04Z"}, {"created_at"=>"2015-03-23T01:55:04Z", "currency_used"=>"BTC", "description"=>nil, "discount"=>nil, "discounted_amount"=>nil, "discounted_item_id"=>nil, "id"=>2, "original_id"=>nil, "price"=>"4500000.0", "price_after_product_discounts"=>nil, "price_extend"=>"4500000.0", "product_sku"=>"0001", "qty"=>1, "sale_id"=>2, "shipping_cost"=>"0.0", "shipping_cost_btc"=>0, "shipping_cost_usd"=>"0.0", "updated_at"=>"2015-03-23T01:55:04Z"}]
    discounts = []
    addresses = [{"address1"=>"-----BEGIN PGP MESSAGE-----\nVersion: haneWIN JavascriptPG v2.0\n\nhQEMAxi+vIcfDgArAQgAkkLLYWOzmHDrknH9NWLjTz7cmMN6Da7Oqz57WFQS\n3vdFb/72BrdpHnzZRmZNIWBH4Vj7sUcKv0X2Q+WL45qQSELEdOawpgGVvS9A\nXrqzAJxbTBKTpyqszqfD/Q8pTMnCIXo0S1zJERBpqLvxQF2rO+sytMn6x9xZ\n2ZFKWtpSfcYxR89itnCK3tCBNHH9hJG+ej/oFsXwJgddVuSnRRSPPW6Ea/W2\n9G4xuOVnDwpfOLGj7wfP6+AlMuJCGTN6Urd18eGyFiYP+WaPvk51yS4jkzOi\nkqRbRLTIvsEiK2KcVyEd6F/NxqTLD7Nw5ADxHyVZzOiNPJKTmwf7diaP8mdm\nyqQzC8c5mfPzWhop3DYJXzL2Y4Mgk7qxR08RKIewTR/SWLtlRnFOwT+itBQN\nN4nD1x19T0Wp\n=dsyQ\n-----END PGP MESSAGE-----\n", "address2"=>"-----BEGIN PGP MESSAGE-----\nVersion: haneWIN JavascriptPG v2.0\n\nhQEMAxi+vIcfDgArAQf6AloPtxXYB+OGv+MnFgQofqs6CEMbKoSf45c+hk6c\nZMpqr9/R/ZK6I7Nbla/FCbKmAtttZ0T6I1GAS/6ivFDJ8J7Y7bhag2tueP86\ntMfyTL6j6VQGOEu7AoMrx58vk76bC2DYG8BAw42y6lHifz8X9IJAzrccyjT4\nHzYmUmoM2sma3qHuN1PZp24qZJqHEOGr8XhpTzaDXuIp00P3+X0NVoLzaZUS\ncgxObRImRzHyRSzSHKRnnbTKHg7SKn43J2lpkJV07bqP8HLNTGYG1YzUigjp\nPydGX0l1sLjo4I3KTmBetjs5s4sJTH3QqqYq/Dfqfch5/MqE92LrNlxzCtgc\ncKQwpTllOo0smnSBLrTnixgEy0mfhUlmVjasEoG9DxD0yinJR+9TeCeskPQk\nKdXI8L/O\n=Mx2r\n-----END PGP MESSAGE-----\n", "apt"=>"-----BEGIN PGP MESSAGE-----\nVersion: haneWIN JavascriptPG v2.0\n\nhQEMAxi+vIcfDgArAQf/QWtqnGOuYOQqhdv9rot0N8altMdgso71Deub2YqH\nyVSrrLhzpvT6mPmNJXHOuS0AtamnNjeMbiJRmkf3m6l56BMYlz904GIbG3Zr\nzzJcr8A+N30afhMO/kmZZfK5mjLfKHiyPA71HN5Kd3J8N9aWYwj9HDm3tCSB\ndsOvcZ5QXkXwzIj+jtOV1201PvwMyShmTgZqCM7c0OwR/sFKBOhx33tcZKWx\nW+k0jbfZJb0RUv95jPuQIeS180O5BRWSUC2tOXaCkgT9u6pC41sRjTZnuH+3\nv/DIhV7uyf46f00sCcwpxPedtrchydh+Daww7sPpdQpRKWtk19a+iIIo8Rvt\n7KQkA0Y5WuvhTQbdfq8deJzUwqUKJtGVGPcps1PMeIMe6ZTLi0ru\n=Gmsg\n-----END PGP MESSAGE-----", "city"=>"-----BEGIN PGP MESSAGE-----\nVersion: haneWIN JavascriptPG v2.0\n\nhQEMAxi+vIcfDgArAQgAqPKhl8LbI8Fs+zasPS3a61CWCS8Aus7UgR8Bf3Eu\n4UBPOA7B3U4YQXhMoxMYGl/JN0C6IctjkP6PwyKXvNTgpKG1WKuki8/hKKZg\njPLhiDwZeFggzCTqC0GxublCrQOPZjHNUufShCY5D1g/iTKTO3VCuilUDyBj\nt3ExgO8k/SgdfbzzrKNe3TktJTOFMOenwr0QQg51B3XrBLih5/ssHWVnrs06\nmBlC6jucHY/tuPIAiQj7xJBpncUHJZbqbvkm0xsb8QFFzSoNyCV+3rekpil5\nYlbb9i3Vtr7BIwEowHvqjKaubEy58bxk7F+P5XrLj+yabV9vzUH1xeqFkEwY\n3KQq1wOGUHMqR9hmZZfkT70jIo3/+7Wxd8g+RZnH6Sh0jQ6E8i4wTtVgjoCV\n\n=ZHnk\n-----END PGP MESSAGE-----\n", "code_name"=>"My House 5", "country"=>"-----BEGIN PGP MESSAGE-----\nVersion: haneWIN JavascriptPG v2.0\n\nhQEMAxi+vIcfDgArAQgArZZDnWPNSpRwVLfzAuhcOXN0CpX8X70ZeN7pUkUS\nQomf5LpvQ+31dVgCdOpkcf/NgL5fnr7CaJLQ7ovC3f9tz+oxirfRT/SueGL5\nhDqQIPE23y0UPoLeNBh8krzhz72o9fQAa3fHG50KCgJpizyUHXaOxo8i8+eA\nkzcGTaL12jeTrDSxoy8xGj/xZyS/m1HbcJ7ZdVSChZt72xe/Cj4epgC1SD4b\nvm7Ki90EOcY8NylRBeR8/yFKsY3YSE+kF7snD94N2M2O9or+wgT61iXZMYf0\ntKeK1woU4C+SnBIo+H+Aa6X4s3OGiFH0GyTxfr+C0r4FzSTO1LcioIq5m6GS\nWqQiVhyzg6XScDqB3Je7CGEEjA6oFzOmQmn3Rsa2ZnYNHaqP6g==\n=RvKD\n-----END PGP MESSAGE-----\n", "created_at"=>"2015-03-23T01:55:04Z", "encryption_pair_id"=>1, "erroneous"=>false, "first_name"=>"-----BEGIN PGP MESSAGE-----\nVersion: haneWIN JavascriptPG v2.0\n\nhQEMAxi+vIcfDgArAQf/UTM9RsZfkWBG3PzkHzm6GtCBmjXAwbHeSg00rKIe\nMdikzxnm464wG1sM0WDJeQCVQGzGIAkxfvOPU4rnfhq6x/NJpI7WuC4X1uJw\niyxiZnpT/A2PEYdlWbUZQWeeadEgAMdI+yiPJ/SHbQrmWDwLEhpKtwCqjMYi\nhtJt1W1l+lhAMdGvXh6nIVyQWiqm9+pQrEvewWIAKsxcFk2OGKSfMRRtivWl\nECNCI8z8h0WdIythAVHTJ8CzmEszYuMWRG7LUMhUs3IHNAtCWkoRojISY1/4\nKqSqQlhpMwJmYGebPhGiAarpmjtltZA/Dy7ERFfctoLxjE7BkRK7HXnq13XW\n4qQk0lyBxx/TadYmlCzDu/B6riOUsbCHJQiwQPpv9+D/CPdK9NWI\n=Awa8\n-----END PGP MESSAGE-----\n", "id"=>1, "last_name"=>"-----BEGIN PGP MESSAGE-----\nVersion: haneWIN JavascriptPG v2.0\n\nhQEMAxi+vIcfDgArAQf+O6lcxOYNW9a4E46TUfcYm4dSoUeEMXKjdk9RmWvj\no49h2EOWbjR+LoyAYFah9GF8ydBwkrI47dyeokZDJq9lnHQrZdO3BEPzEfd3\nxZ7bPAH7kVennN4kkon/uh5cnwQdFcIQufkUWPePIOTM37GVEMwiUWSAk6Tv\nsd/hC11UraLgJV/iQ1PKYrQ1k9JFab4qYMNg3vdJCS2i5EmVUldlhxhw2odq\nU0e03FM0zjA6oe7/zoci7tYRsvMbDIr7gnNk75s4xKHmA73879uiEgCUXisd\nEJtAiCoAi357VJvIGM9p/rLAzBiL3Q8K3LWKWVzjvPp5tIIQZMAF50FF/f9u\nA6Qjh6R1leS5aGd6NwEzd6udN4hM+ORUDMUrKNgjGcFhzwFnTrE=\n=bbtQ\n-----END PGP MESSAGE-----\n", "original_id"=>nil, "phone"=>nil, "state"=>"-----BEGIN PGP MESSAGE-----\nVersion: haneWIN JavascriptPG v2.0\n\nhQEMAxi+vIcfDgArAQgAwSy1/X1hRxDkEgX0WTe8EWKCyacxW2J4jvv5/kDM\nZBpOLi78KCCVokrp2hmdkTzM0aJQl45/dkImVOYOpXb9ulnCJXbmpyF6398d\nvbGTvjtLXQSaJ41LbCGxu32L1bCQsrBUIORqqL/+C9gdqrMmYItWDXwN2do5\nWfVhJShOJEWULSUrhYOC40BuRLKNrv2ruk48bh7Mdn7DQbaBa0jT4iV6flK7\nmFvZfAULPOM40UBJ9aCF/GQGBR7lPM3SiaUHfi3rWQihjpUEmHE1l/ui7FWw\n+FiaKvKWhvECAIo5iV9V/sUPGj3Zw5JEDFX9J4GS6zry2G9/sU1Ka7nOQx3F\nOqQnazqWUIMO9WCMZRV/6gnw7rbOr897ikGXvOdoMY4scVb8dz8bbLT9\n=s04T\n-----END PGP MESSAGE-----\n", "updated_at"=>"2015-03-23T01:55:04Z", "user_id"=>1, "zip"=>"-----BEGIN PGP MESSAGE-----\nVersion: haneWIN JavascriptPG v2.0\n\nhQEMAxi+vIcfDgArAQgAqyLtfr8yy9aRSNCKy9UTNVhVFFs1ABozP2QUUKVJ\nfA/oUeAntTmeFz1Ga7HC1g8iyefE1G/Y2PEaHCSj1JFqczOJS13XgRYO45AK\nd9dTLLjl+qElVx78M06mIoXUaeSuaex0X/3qNXauCIeGJpaBf9xMLMlYbxH8\nzW3Q1j15VnQz6MFuwoYNXfABc2ekLve076UvUCxbn0G598VmCHHCD28u+Oec\nsuuxebOcjQWbFNsLoGTpKS+OecilkQ98H1cPkLD7qZHluGWP+0WCOCkg1Ttq\nvW+ibdmGW30fq/1EKprJchayANgGdMd/ynbduG0Nn0pGYUk+y5WBucMDINGS\nZKQlHHtkqVBbH14dmx81aGg2gblp6PVaa/fmFw/2FP385ARJ1mRT3w==\n=PlFx\n-----END PGP MESSAGE-----\n"}, {"address1"=>"-----BEGIN PGP MESSAGE-----\nVersion: haneWIN JavascriptPG v2.0\n\nhQEMAxi+vIcfDgArAQgAkkLLYWOzmHDrknH9NWLjTz7cmMN6Da7Oqz57WFQS\n3vdFb/72BrdpHnzZRmZNIWBH4Vj7sUcKv0X2Q+WL45qQSELEdOawpgGVvS9A\nXrqzAJxbTBKTpyqszqfD/Q8pTMnCIXo0S1zJERBpqLvxQF2rO+sytMn6x9xZ\n2ZFKWtpSfcYxR89itnCK3tCBNHH9hJG+ej/oFsXwJgddVuSnRRSPPW6Ea/W2\n9G4xuOVnDwpfOLGj7wfP6+AlMuJCGTN6Urd18eGyFiYP+WaPvk51yS4jkzOi\nkqRbRLTIvsEiK2KcVyEd6F/NxqTLD7Nw5ADxHyVZzOiNPJKTmwf7diaP8mdm\nyqQzC8c5mfPzWhop3DYJXzL2Y4Mgk7qxR08RKIewTR/SWLtlRnFOwT+itBQN\nN4nD1x19T0Wp\n=dsyQ\n-----END PGP MESSAGE-----\n", "address2"=>"-----BEGIN PGP MESSAGE-----\nVersion: haneWIN JavascriptPG v2.0\n\nhQEMAxi+vIcfDgArAQf6AloPtxXYB+OGv+MnFgQofqs6CEMbKoSf45c+hk6c\nZMpqr9/R/ZK6I7Nbla/FCbKmAtttZ0T6I1GAS/6ivFDJ8J7Y7bhag2tueP86\ntMfyTL6j6VQGOEu7AoMrx58vk76bC2DYG8BAw42y6lHifz8X9IJAzrccyjT4\nHzYmUmoM2sma3qHuN1PZp24qZJqHEOGr8XhpTzaDXuIp00P3+X0NVoLzaZUS\ncgxObRImRzHyRSzSHKRnnbTKHg7SKn43J2lpkJV07bqP8HLNTGYG1YzUigjp\nPydGX0l1sLjo4I3KTmBetjs5s4sJTH3QqqYq/Dfqfch5/MqE92LrNlxzCtgc\ncKQwpTllOo0smnSBLrTnixgEy0mfhUlmVjasEoG9DxD0yinJR+9TeCeskPQk\nKdXI8L/O\n=Mx2r\n-----END PGP MESSAGE-----\n", "apt"=>"", "city"=>"-----BEGIN PGP MESSAGE-----\nVersion: haneWIN JavascriptPG v2.0\n\nhQEMAxi+vIcfDgArAQgAqPKhl8LbI8Fs+zasPS3a61CWCS8Aus7UgR8Bf3Eu\n4UBPOA7B3U4YQXhMoxMYGl/JN0C6IctjkP6PwyKXvNTgpKG1WKuki8/hKKZg\njPLhiDwZeFggzCTqC0GxublCrQOPZjHNUufShCY5D1g/iTKTO3VCuilUDyBj\nt3ExgO8k/SgdfbzzrKNe3TktJTOFMOenwr0QQg51B3XrBLih5/ssHWVnrs06\nmBlC6jucHY/tuPIAiQj7xJBpncUHJZbqbvkm0xsb8QFFzSoNyCV+3rekpil5\nYlbb9i3Vtr7BIwEowHvqjKaubEy58bxk7F+P5XrLj+yabV9vzUH1xeqFkEwY\n3KQq1wOGUHMqR9hmZZfkT70jIo3/+7Wxd8g+RZnH6Sh0jQ6E8i4wTtVgjoCV\n\n=ZHnk\n-----END PGP MESSAGE-----\n", "code_name"=>"My House 9", "country"=>"-----BEGIN PGP MESSAGE-----\nVersion: haneWIN JavascriptPG v2.0\n\nhQEMAxi+vIcfDgArAQgArZZDnWPNSpRwVLfzAuhcOXN0CpX8X70ZeN7pUkUS\nQomf5LpvQ+31dVgCdOpkcf/NgL5fnr7CaJLQ7ovC3f9tz+oxirfRT/SueGL5\nhDqQIPE23y0UPoLeNBh8krzhz72o9fQAa3fHG50KCgJpizyUHXaOxo8i8+eA\nkzcGTaL12jeTrDSxoy8xGj/xZyS/m1HbcJ7ZdVSChZt72xe/Cj4epgC1SD4b\nvm7Ki90EOcY8NylRBeR8/yFKsY3YSE+kF7snD94N2M2O9or+wgT61iXZMYf0\ntKeK1woU4C+SnBIo+H+Aa6X4s3OGiFH0GyTxfr+C0r4FzSTO1LcioIq5m6GS\nWqQiVhyzg6XScDqB3Je7CGEEjA6oFzOmQmn3Rsa2ZnYNHaqP6g==\n=RvKD\n-----END PGP MESSAGE-----\n", "created_at"=>"2015-03-23T01:55:04Z", "encryption_pair_id"=>1, "erroneous"=>false, "first_name"=>"-----BEGIN PGP MESSAGE-----\nVersion: haneWIN JavascriptPG v2.0\n\nhQEMAxi+vIcfDgArAQf/UTM9RsZfkWBG3PzkHzm6GtCBmjXAwbHeSg00rKIe\nMdikzxnm464wG1sM0WDJeQCVQGzGIAkxfvOPU4rnfhq6x/NJpI7WuC4X1uJw\niyxiZnpT/A2PEYdlWbUZQWeeadEgAMdI+yiPJ/SHbQrmWDwLEhpKtwCqjMYi\nhtJt1W1l+lhAMdGvXh6nIVyQWiqm9+pQrEvewWIAKsxcFk2OGKSfMRRtivWl\nECNCI8z8h0WdIythAVHTJ8CzmEszYuMWRG7LUMhUs3IHNAtCWkoRojISY1/4\nKqSqQlhpMwJmYGebPhGiAarpmjtltZA/Dy7ERFfctoLxjE7BkRK7HXnq13XW\n4qQk0lyBxx/TadYmlCzDu/B6riOUsbCHJQiwQPpv9+D/CPdK9NWI\n=Awa8\n-----END PGP MESSAGE-----\n", "id"=>5, "last_name"=>"-----BEGIN PGP MESSAGE-----\nVersion: haneWIN JavascriptPG v2.0\n\nhQEMAxi+vIcfDgArAQf+O6lcxOYNW9a4E46TUfcYm4dSoUeEMXKjdk9RmWvj\no49h2EOWbjR+LoyAYFah9GF8ydBwkrI47dyeokZDJq9lnHQrZdO3BEPzEfd3\nxZ7bPAH7kVennN4kkon/uh5cnwQdFcIQufkUWPePIOTM37GVEMwiUWSAk6Tv\nsd/hC11UraLgJV/iQ1PKYrQ1k9JFab4qYMNg3vdJCS2i5EmVUldlhxhw2odq\nU0e03FM0zjA6oe7/zoci7tYRsvMbDIr7gnNk75s4xKHmA73879uiEgCUXisd\nEJtAiCoAi357VJvIGM9p/rLAzBiL3Q8K3LWKWVzjvPp5tIIQZMAF50FF/f9u\nA6Qjh6R1leS5aGd6NwEzd6udN4hM+ORUDMUrKNgjGcFhzwFnTrE=\n=bbtQ\n-----END PGP MESSAGE-----\n", "original_id"=>nil, "phone"=>nil, "state"=>"-----BEGIN PGP MESSAGE-----\nVersion: haneWIN JavascriptPG v2.0\n\nhQEMAxi+vIcfDgArAQgAwSy1/X1hRxDkEgX0WTe8EWKCyacxW2J4jvv5/kDM\nZBpOLi78KCCVokrp2hmdkTzM0aJQl45/dkImVOYOpXb9ulnCJXbmpyF6398d\nvbGTvjtLXQSaJ41LbCGxu32L1bCQsrBUIORqqL/+C9gdqrMmYItWDXwN2do5\nWfVhJShOJEWULSUrhYOC40BuRLKNrv2ruk48bh7Mdn7DQbaBa0jT4iV6flK7\nmFvZfAULPOM40UBJ9aCF/GQGBR7lPM3SiaUHfi3rWQihjpUEmHE1l/ui7FWw\n+FiaKvKWhvECAIo5iV9V/sUPGj3Zw5JEDFX9J4GS6zry2G9/sU1Ka7nOQx3F\nOqQnazqWUIMO9WCMZRV/6gnw7rbOr897ikGXvOdoMY4scVb8dz8bbLT9\n=s04T\n-----END PGP MESSAGE-----\n", "updated_at"=>"2015-03-23T01:55:04Z", "user_id"=>2, "zip"=>"-----BEGIN PGP MESSAGE-----\nVersion: haneWIN JavascriptPG v2.0\n\nhQEMAxi+vIcfDgArAQgAqyLtfr8yy9aRSNCKy9UTNVhVFFs1ABozP2QUUKVJ\nfA/oUeAntTmeFz1Ga7HC1g8iyefE1G/Y2PEaHCSj1JFqczOJS13XgRYO45AK\nd9dTLLjl+qElVx78M06mIoXUaeSuaex0X/3qNXauCIeGJpaBf9xMLMlYbxH8\nzW3Q1j15VnQz6MFuwoYNXfABc2ekLve076UvUCxbn0G598VmCHHCD28u+Oec\nsuuxebOcjQWbFNsLoGTpKS+OecilkQ98H1cPkLD7qZHluGWP+0WCOCkg1Ttq\nvW+ibdmGW30fq/1EKprJchayANgGdMd/ynbduG0Nn0pGYUk+y5WBucMDINGS\nZKQlHHtkqVBbH14dmx81aGg2gblp6PVaa/fmFw/2FP385ARJ1mRT3w==\n=PlFx\n-----END PGP MESSAGE-----\n"}]
    ubws = [{"created_at"=>"2015-03-23T01:55:04Z", "id"=>1, "original_id"=>nil, "updated_at"=>"2015-03-23T01:55:04Z", "wallet_address"=>"1FWNSL4HZy7pW2zRHanR2t72nvw7VdLVuB"}]
    encryption_pairs = [{"created_at"=>"2015-03-23T01:55:04Z", "id"=>1, "original_id"=>nil, "private_key"=>nil, "public_key"=>"-----BEGIN PGP PUBLIC KEY BLOCK-----\nVersion: GnuPG v1.4.12 (GNU/Linux)\n\nmQENBFLm15sBCADGEjoJw/ATyPYC+3er/XiZsCCht6t1Kr8p6fXVI9h7cyvoTulM\n31iug8kFvIr/dggNtEVYjnzuk6ervf2mit5uw3wgs8BBDGOj7BLg6kfuEUjsRaRO\nlCNKKneuscCBvyDbilsnc9jOdc7Nz4wpa8nwLh9iM6GqcM90pClaGYsDAYSFL7Kz\nHiTkBeDeo6pQS2p7G7p+Fg498OrpvythBtwhNiVL01X8f2zaGhlkTaDThJm5qofG\nlal552FitRtJuwu6Tim2Fef2jqJoEb0Hxc4o59/kKm+hqYlW0p5qleKm/hNWDSp1\nFA4VlUP7IPqPa5mzrIIrpRhDRZaIkdGAqWchABEBAAG0EWFiY2RlIChhKSA8YUBi\nLmM+iQE4BBMBAgAiBQJS5tebAhsDBgsJCAcDAgYVCAIJCgsEFgIDAQIeAQIXgAAK\nCRAdhYud6iaPu+yoB/4lyX2WTLFQWKCYavU4OzSiRSwSg33LAa/hj9as4jDUErg0\nIPl2dm3QMpf57jny1stqEDAVBQ3eyff5LqmJnhf6YyfroyfCMuTbY4woNyaY2IC0\nXJlBdMlUAOoWcHZCfl4ud97vW+XfRky/uZsmjUBh5DymL2f0fVFxwIeXl/k0hOti\n0FY6l7EGl0I9MQp5dPdqJonsAv1KnjdclsqmLDu7cFWHNF+BHCTb3xkDs0kqShvs\nA8o8HrD/9kUxdRSVdO+VQrZaimI6XdNWHzI4pEYQHQtnZ0IA1aOyzcqWpyTSlyy8\n1QzyNAvXQ4gzrpqRwdrdqUjuEwUTJoLKRSyYQ8yCuQENBFLm15sBCADI6MESgCQH\nf2JIjsHk2owRMpEhjyr25pEktjTpf8zLy5LYwHgwZXwpc6zDnwMBV6PcaPI6ZTRF\nGfwY4GsL9DBLefbiZuvYghYi++cevG11V87XhoRx8u8FGPukjRyKs4gCTrHW2g9q\n8IES46GZalCkC4x8WDM68yWutO/22ie7eALjMU+Ju9lbrwUI4/uy6a9dQJLMPdXN\ncYnWQO/q/CpkcngnoKEjreJ9FszrdSFtd+cBoItknsX668Euf4IIPwCW/KUfGZMm\n/Js/3pZRQpqq+OryuKcB03YsMd5E/JE+DySUo19rPeA2xwXLlW5goA9JL0YCvqW/\ntmEwvwDoVlW5ABEBAAGJAR8EGAECAAkFAlLm15sCGwwACgkQHYWLneomj7tfowgA\ngKRy023Oa6rYKwEZlQRWc7gL27Z8V9vCFgBaMM4cNFqrKqY97VezZ6ldjYqd6AGJ\nGWbrG8SqVZ4ZyoksyWnweMYKqoRGIcX7LEuL97mc6W7bB5MRGL9zQRIxu0/KHVik\nVZ8PL3f4j4XdPuF0gRLPBIDOOZVGqf86NpnKLx1XEIaS/z3OqxyWkRR47oOquqpd\nNd4Gn1hDZlTgiSsaSf6aFdS6O2eDLaseZ2l0WgrWoUMjD5bzmKgpmaJAJ+CcfuvB\nP1O44KOH9l+pRzKCbr6nlfd8rbQ4kehjIaGchdehvLFv9WQWMH9uDkKgIu3BGGkp\nJ1TdTyeCX++qX0MtJ79GDw==\n=ToNu\n-----END PGP PUBLIC KEY BLOCK-----\n", "test_value"=>nil, "tested"=>nil, "updated_at"=>"2015-03-23T01:55:04Z"}]
    rfsb = {"acf_integrity_hash"=>nil, "batch_stamp"=>"2015-03-23_01.55.042", "created_at"=>"2015-03-23T01:55:04Z", "id"=>1, "original_id"=>nil, "sale_id"=>nil, "sf_integrity_hash"=>"c39c2be15b918842604261d8daf9ef1535842a7d558d0b6f2114a9404dd453d8", "updated_at"=>"2015-03-23T01:55:04Z"}
    
    nm_data = NmDatafile.new(:shippable_file, sales, line_items, discounts, addresses, ubws, encryption_pairs, rfsb)
    nm_data.sales.count.should eq 2
    
    #nm_data.save_to_file(@binary_nmd_path)
    
  end
  
  it "should be able to load data from a binary string" do
    nmd_binary_string = File.read(@binary_nmd_path)
    
    nmd_file = NmDatafile::load_binary_data nmd_binary_string
    
    sales = nmd_file.sales
    line_items = nmd_file.line_items
    discounts = nmd_file.discounts
    addresses = nmd_file.addresses
    ubws = nmd_file.ubws
    encryption_pairs = nmd_file.encryption_pairs
    rfsb = nmd_file.ready_for_shipment_batch
    
    nm_data = NmDatafile.new(:shippable_file, sales, line_items, discounts, addresses, ubws, encryption_pairs, rfsb)
    
    nm_data.sales.count.should eq 2
    nm_data.ready_for_shipment_batch["batch_stamp"].should eq rfsb["batch_stamp"]
  end

  it "should be able to load data from a path to a zip" do
    
    nmd_string_loaded = NmDatafile::load_binary_data File.read(@binary_nmd_path)
    
    nmd_path_loaded = NmDatafile::Load @binary_nmd_path
    
    nmd_string_loaded.sales.should eq nmd_path_loaded.sales
  end

  it "should be able to save data as a zip string" do
    nmd_shippable = NmDatafile.new(:shippable_file, *@sample_data)
    
    nmd = NmDatafile::load_binary_data nmd_shippable.save_to_string
    
    nmd.sales.should eq @sample_data.first
  end
  
  it "should be able to load in the attributes" do
    nmd = NmDatafile::Load @binary_nmd_path
    
    nmd.file_type.should eq :shippable_file
  end
  
  it "fast_encrypt_string_with_pass and fast_decrypt_string_with_pass reverse" do
    original_string = "hello"
    
    pass = NmDatafile::FRONT_DOOR_KEY
    
    encrypted_string = NmDatafile::fast_encrypt_string_with_pass(pass, original_string)
    
    clear_text = NmDatafile::fast_decrypt_string_with_pass(pass, encrypted_string)
    
    clear_text.should eq original_string
  end
  
  


end


