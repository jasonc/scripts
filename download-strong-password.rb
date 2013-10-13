#!/usr/bin/env ruby

# Usage: download-strong-password.rb
# Downloads and prints the "63 random printable ASCII character" password from https://www.grc.com/passwords.htm.

require 'nokogiri'   
require 'open-uri'  

password_url = 'https://www.grc.com/passwords.htm'
doc = Nokogiri::HTML(open(password_url))
puts doc.xpath("//html/body/center/center[2]/table[2]/tr/td/table/tr/td/table/tr/td").text
