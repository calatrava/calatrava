module IPhone
  class StationsScreen
    include ScreenMixin

    def search_for_station(station_name)
      search_bar_selector = %Q|view:'UISearchBarTextField'|
      touch(search_bar_selector)
      frankly_map( search_bar_selector, 'setText:', station_name )
      wait_for_nav_animation
    end

    def nav_to_station(station_name)
      search_for_station(station_name)
      touch( %Q|tableViewCell view:'UILabel' marked:'#{station_name}' parent tableViewCell| )
      
      wait_for_view_to_disappear( 'Loading' )
    end
  end
end
