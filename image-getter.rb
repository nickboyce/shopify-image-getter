#!/usr/bin/env ruby
require 'hpricot'
require 'open-uri'
require 'net/http'
require_relative 'config'

@sizeArray = ["pico", "icon", "thumb", "small", "compact", "medium", "large", "grande", "original"]

def saveXML(page=1)
  Net::HTTP.start(@shopifyShopURL) {|http|
    req = Net::HTTP::Get.new("/admin/products.xml?limit=250&page=2")
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

def parseXML(doc)
  doc.search("//image/src").each do |i|
    url = i.inner_text
    # puts getURL(url, "compact")
    filename = url[url.rindex("/")+1..url.rindex("?")-1]
    @sizeArray.each do |theSize|
      # create directory if it doesn't exist
      unless File::directory?(theSize) then 
        Dir::mkdir(theSize)
        puts "Creating directory: #{theSize}"
      end
      
      filePath = "#{theSize}/#{getURL(filename, theSize)}"
      # save the file if it doesn't exist
      if !FileTest.exist?(filePath)
        puts "getting: #{getURL(url, theSize)}"
        open(filePath, 'wb') do |file|
          file << open(getURL(url, theSize)).read
        end
      else
        puts "exists: #{filePath}"
      end
    end
  end
end

# get the XML
saveXML()
doc = Hpricot(open("products.xml"))
parseXML(doc);