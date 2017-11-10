#!/usr/bin/env ruby
# Brian W. Gray
# Original creation date: 11.10.2017
#
# Purpose: Parse plist output for a macos hash (10.8+) and format the hash for hashcat cracking
# The following is an example for extracting the base information needed for this script
# sudo defaults read /var/db/dslocal/nodes/Default/users/admin.plist ShadowHashData|tr -dc 0-9a-f|xxd -r -p|plutil -convert xml1 - -o extracted.plist
#
## Script performs the following
## 1.) Parses extracted.plist
## 2.) generates generated.hash

## ToDo
## 1.) reduce required gems to perform actions with native code

# Require gems
require 'active_support/core_ext/hash'
require 'nokogiri'
require 'base64'

# default file location
macosFile = "./extracted.plist"
hashFilename = "./generated.hash"
if ARGV.length < 1
	puts "No plist file provided try #{__FILE__} extracted.plist generated.hash"
else
	macosFile = ARGV[0] # => "extracted.plist"
	if(ARGV[1])
		hashFilename = ARGV[1]
	end
end

module HexString
	def to_hex_string(readable = true)
	    unpacked = self.unpack('H*').first
	    if readable
	      unpacked.gsub(/(..)/,'\1 ').rstrip
	    else
	      unpacked
	    end
	end
end

# Include HexString extensions in the String class
class String
	include HexString
end

# quick and dirty hack to convert the XML to Hash
doc = Nokogiri::XML(File.read(macosFile))
hashData = Hash.from_xml(doc.to_xml)

# this block depends on the item location within the extracted plist to always be the same.
iterations = hashData['plist']['dict']['dict'][0]['integer'].gsub(/\n\t\t/,"")
salt = Base64.decode64(hashData['plist']['dict']['dict'][0]['data'][1]).to_hex_string(false)
entropy = Base64.decode64(hashData['plist']['dict']['dict'][0]['data'][0]).to_hex_string(false)

extractedHash = "$ml$#{iterations}$#{salt}$#{entropy}"

puts
puts "Hash:"
puts extractedHash
puts

File.open(hashFilename, 'w') { |file| file.write(extractedHash) }

