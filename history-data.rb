#!/usr/bin/env ruby

require 'csv'
require 'net/http'
require 'nokogiri'
require 'uri'
require 'yaml'
require 'openssl'
time = Time.now.to_s.gsub!(':','.')
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

config = YAML.load_file('auth.yml')

uri = URI.parse("https://www.dmr.nd.gov/oilgas/feeservices/getwellprod.asp")
request = Net::HTTP::Post.new(uri)
request.content_type = "application/x-www-form-urlencoded"
request["Authorization"] = config['auth']
request.set_form_data(
  "FileNumber" => "#{ARGV[0]}",
  "B1" => "Get Monthly Production Data",
)

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
  http.request(request)
end

page = Nokogiri::HTML(response.body)


rows = []
page.css('table').last.css('tr').each do |tr|
  rows << tr.css('td').map(&:content)
end

puts "Leeeeeroooy Jeenkins!"

CSV.open("well number- #{ARGV[0]} time- "+ time +" .csv", 'w') do |file|
  rows.each do |row|
    file << row
  end
end
