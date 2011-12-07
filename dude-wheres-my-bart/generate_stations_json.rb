require 'rubygems'
require 'bundler/setup'
require 'hashie'
require 'json'

require './bart_extensions'

API_KEY = "MW9S-E7SL-26DU-VV8V"

def station_info( abbr )
  params = {
          :cmd => 'stninfo',
          :orig => abbr,
          :key => API_KEY
        }
  query_string = '?' + params.map { |key, value| [key, value] * '=' } * '&'
  response = Net::HTTP.start('api.bart.gov') do |http|
    http.request( Net::HTTP::Get.new('/api/stn.aspx' + query_string ) )
  end

  doc = Nokogiri::XML.parse(response.body)
  station = doc.xpath('//stations/station')

 
  extracted_values = {}
  {
    :name => :name,
    :abbr => :abbr,
    :gtfs_latitude => :lat,
    :gtfs_longitude => :long,
  }.each do |xml_key,extracted_key| 
    extracted_values[extracted_key] = station.css(xml_key).text
  end
  
  extracted_values
end

all_stations_info = Bart::Station::LIST.inject({}) do |hash,s| 
  id = s[:id]
  hash[id] = station_info(id)
  hash
end

puts JSON.pretty_generate(all_stations_info)
