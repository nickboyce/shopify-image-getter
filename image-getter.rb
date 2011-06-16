#!/usr/bin/env ruby
require 'hpricot'
require 'open-uri'
require 'net/http'

# config
@shopifyAPIKey = "b05b2f4088c15a88cf75a2a72f318ac2"
@shopifyAPIPassword = "98549011183527258f8d6d45a8f100e9"
@shopifyShopURL = "bholu.myshopify.com"

sizeArray = ["pico", "icon", "thumb", "small", "compact", "medium", "large", "grande", "original"]

def saveXML
  Net::HTTP.start(@shopifyShopURL) {|http|
    req = Net::HTTP::Get.new("/admin/products.xml")
    req.basic_auth @shopifyAPIKey, @shopifyAPIPassword
    response = http.request(req)
    # puts response.body into the file products.xml
    open("products.xml", 'wb') do |file|
      file << response.body
    end  
  }
end

def getURL(url, size="")
  # return the 
  if size && size.downcase != "original"
    startFragment = url[0..url.rindex(".")-1]
    endFragment = url[url.rindex(".")..url.length]
    startFragment + "_" + size + endFragment
  else
    url
  end
end
# get the XML
saveXML()
doc = Hpricot(open("products.xml"))
doc.search("//image/src").each do |i|
  url = i.inner_text
  # puts getURL(url, "compact")
  filename = url[url.rindex("/")+1..url.rindex("?")-1]
  sizeArray.each do |theSize|
    # create directory if it doesn't exist
    unless File::directory?(theSize) then 
      Dir::mkdir(theSize)
      puts "Creating directory: #{theSize}"
    end
    puts "getting " + getURL(url, theSize)
    # save the file
    open(theSize + "/" + getURL(filename, theSize), 'wb') do |file|
      file << open(getURL(url, theSize)).read
    end
  end
end