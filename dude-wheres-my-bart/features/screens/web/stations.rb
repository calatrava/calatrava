module Web
  class StationsScreen
    def nav_to_station(station_name)
      $browser.link(:text => /^#{station_name}/).click
    end
  end
end
