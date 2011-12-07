When /^I choose "([^"]*)" from the list of stations$/ do |station_name|
  stations = Device::HomeScreen.new.nav_to_stations
  stations.nav_to_station(station_name)
end

Then /^I should see a train leaving for "([^"]*)" in (\d+) minutes$/ do |dest, etd|
  Device::DeparturesScreen.new.has_departure( :destination => dest, :etd => etd ).should be_true
end

