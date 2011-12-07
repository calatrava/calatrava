require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'json'
require 'hashie'
Mash = Hashie::Mash

require './bart_extensions'

get '/' do
  redirect('/stations')
end

get '/stations' do
  station_links = Bart::Station::LIST.map do |station|
    Mash.new({
      :title => station[:name],
      :href => '/stations/'+station[:id]
    })
  end
    
  haml :stations, :locals => { :station_links => station_links }
end

def reorg_departures( departures )
  flattened = []
  departures.each do |departure|
    departure.estimates.each do |estimate|
      flattened << Mash.new({
        :estimate => estimate,
        :destination => departure.destination
      })

    end
  end

  flattened.sort_by{ |x| x.estimate.minutes }
end


def departures_to_html station, departures
  departure_list = departures.map do |departure|
    dest = departure.destination.name
    etd = departure.estimate.minutes
    when_desc = case etd
                when 0
                  "<span class='minute'>now arriving</span>"
                when 1
                  "in <span class='minute'>1</span> min"
                else
                  "in <span class='minute'>#{etd}</span> min"
                end
           
    Mash.new({
      :text => "<span class='dest'>#{dest}</span> train #{when_desc}",
      :line => departure.estimate.color
    })
  end
  haml :station, :locals => {:station_name => station.name, :departures => departure_list}
end

def departures_to_json departures
  repr = departures.map do |departure|
    {
      :dest_abbr => departure.destination.abbr,
      :dest_name => departure.destination.name,
      :route => departure.estimate.color,
      :etd => departure.estimate.minutes
    }
  end
  JSON.pretty_generate repr 
end

get '/stations/:abbr' do
  abbr = params[:abbr].downcase
  station = Bart::Station.with_abbr(abbr)
  pass unless station

  reorganized_departures = reorg_departures( station.load_departures )

  request.accept.each do |type|
    case type
    when 'text/html', '*/*'
      halt 200, departures_to_html( station, reorganized_departures )
    when 'text/json'
      halt 200, {'Content-Type' => 'text/json'}, departures_to_json( reorganized_departures )
    end
  end
  error 406
end

__END__

@@ layout
%html 
 %head
  %meta(name="HandheldFriendly" content="True")
  %meta(name="MobileOptimized" content="320")
  %meta(name="viewport" content="width=device-width, initial-scale=1.0")

  %title Dude! Where's My Bart?!
  %link(rel="stylesheet" href="/dwmb.css")
  :javascript
    var _gaq = _gaq || [];
    _gaq.push(['_setAccount', 'UA-8198442-4']);
    _gaq.push(['_trackPageview']);

    (function() {
      var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
      ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
      var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
    })();
 %body
  = yield

@@ stations
%h2 Choose A Station
%ul.stations
  -station_links.each do |station_link|
    %li
      %a{:href => station_link.href}
        = station_link.title

@@ station
%h2.station-name 
  = station_name
.choose-another-station
  %a(href="/stations") (choose another station)
%ul.departures
  - departures.each do |departure|
    %li{:class => departure.line}
      = departure.text
      
