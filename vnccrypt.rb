#!/usr/bin/env ruby

# BrianWGray
# 03/08/2019
# Work with encrypted VNC credentials.

# TODO: write options that allow for various actions to be selected instead of running everything each time BrianWGray.

require 'openssl'

vnc_key = [ 23, 82, 107, 6, 35, 78, 88, 7 ]
vnc_key_for_classic_DES = [ 232, 74, 214, 96, 196, 114, 26, 224 ]

key = vnc_key_for_classic_DES.pack('c*')

if ARGV.length < 1
  puts "No password string provided try #{__FILE__} 'dbd83cfd727a1458'"
else
  macosFile = ARGV[0] # => "dbd83cfd727a1458"
  if(ARGV[0])
    original_string = ARGV[0]
  end
end

def des_decrypt(ciphertext, key)
  # We must pad content to 8 for great success + (null termination)
  # This is a rediculous padding solution that needs to be implemented better - BrianWGray
  padded_ciphertext = [ ciphertext + '0000000000000000' ].pack('H*')[0..8]
  cipher = OpenSSL::Cipher::Cipher.new('DES')
  cipher.decrypt
  cipher.key = key
  result = cipher.update(padded_ciphertext)

  return result
end

def des_encrypt(ciphertext, key)
  cipher_bytes = ciphertext.bytes
  # This is a rediculous padding solution that needs to be implemented better - BrianWGray
  cipher_bytes << 00 << 00 << 00 << 00 << 00 << 00 << 00 << 00
  padded_ciphertext = cipher_bytes.pack('C*')[0..8]
  cipher = OpenSSL::Cipher::Cipher.new('DES')
  cipher.encrypt
  cipher.key = key
  result = cipher.update(padded_ciphertext)

  return result.unpack("H*").first
end

decrypted = des_decrypt(original_string, key)
puts ("Orginal String: #{original_string}")
puts ("Decrypted: #{decrypted}\r\n")

encrypted = des_encrypt(original_string, key)
puts ("Encrypted: #{encrypted}")