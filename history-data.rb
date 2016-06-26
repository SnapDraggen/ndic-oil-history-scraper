#!/usr/bin/env ruby

require 'csv'
require 'net/http'
require 'nokogiri'
require 'uri'
require 'yaml'
require 'openssl'

class WellParser
  attr_accessor :file_number

  def initialize(uri, auth, file_number)
    @uri = URI.parse(uri)
    @auth = auth
    @file_number = file_number
    get_well_data
    parse_html
  end

  def get_well_data
    request = Net::HTTP::Post.new(@uri)
    request["Authorization"] = @auth
    request.content_type = "application/x-www-form-urlencoded"
    request.set_form_data(
      "FileNumber" => "#{@file_number}",
      "B1" => "Get Monthly Production Data",
    )
    @response = Net::HTTP.start(@uri.hostname, @uri.port, use_ssl: @uri.scheme == "https") do |http|
      http.request(request)
    end
  end

  def parse_html
    @page = Nokogiri::HTML(@response.body)
  end

  def get_header_row
    @page.css('table').last.css('th').map(&:content)
  end

  def get_data_rows
    rows = []
    @page.css('table').last.css('tr').each do |tr|
      rows << tr.css('td').map(&:content)
    end
    rows
  end

  def to_s
    "Well Number: #{@file_number}"
  end
end

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

config = YAML.load_file('auth.yml')

wells = []
ARGV.each do |file_number|
  wells << WellParser.new("https://www.dmr.nd.gov/oilgas/feeservices/getwellprod.asp", config['auth'], file_number)
end

wells.each do |well|
  CSV.open("well-number-#{well.file_number}-Date-#{Time.now.strftime('%Y-%m-%d')}.csv", 'w') do |file|
    file << well.get_header_row
    well.get_data_rows.each do |row|
      file << row
    end
  end
end

unless ARGV[1] == nil
  CSV.open("Multi-Well-Date-#{Time.now.strftime('%Y-%m-%d')}.csv", 'w') do |file|
    file << wells.first.get_header_row
    wells.each do |well|
      file << [well]
      well.get_data_rows.each do |row|
        file << row
      end
    end
  end
end