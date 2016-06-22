#!/usr/bin/env ruby

require 'csv'
require 'net/http'
require 'nokogiri'
require 'uri'
require 'yaml'

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
  rows << tr.css('td').map(&:content).join(',')
end

CSV.open("output-#{ARGV[0]}-#{DateTime.now.to_time.to_i}.csv", 'w') do |file|
  rows.each do |row|
    file << row.parse_csv
  end
end
