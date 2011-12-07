module IPhone
  module ScreenMixin
    include Frank::Cucumber::FrankHelper

    def wait_for_nav_animation
      sleep 0.5
    end

    def wait_while
      Timeout::timeout(WAIT_TIMEOUT) do
        while yield
          sleep 0.1
        end
      end
    end

    def wait_for_view_to_disappear(mark)
      sleep 0.8 # give the view a chance to appear
      wait_while { element_exists( "view marked:'#{mark}'" ) }
    end
  end
end
