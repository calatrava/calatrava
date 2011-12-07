require 'cucumber/rspec/doubles'

Given /^BART says there is a train leaving from "([^"]*)" for "([^"]*)" in (\d+) minutes$/ do |station, destination, etd|
  stub_estimate = mock( 'estimate', :color => 'blah', :minutes => etd )
  stub_destination = mock( 'destination', :name => destination, :abbr => 'blah' )
  stub_departure = mock( 'departure', :estimates => [stub_estimate], :destination => stub_destination )
  stub_station = mock( Bart::Station, :load_departures => [stub_departure], :name => 'blah' )
  Bart::Station.stub!(:with_abbr).with(station).and_return(stub_station)
end
