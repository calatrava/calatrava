module IPhone
  class HomeScreen
    include Frank::Cucumber::FrankHelper

    def nav_to_stations
      touch( %Q|view marked:'Choose a station'| )
      StationsScreen.new
    end
  end
end
