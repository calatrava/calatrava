require 'watir-webdriver'

module Web
  def self.setup
    chromedriver_path = File.expand_path( File.join( File.dirname(__FILE__),'..','..','tools','chromedriver' ) )
    Selenium::WebDriver::Chrome.driver_path = chromedriver_path
    $browser = Watir::Browser.new( :chrome )
  end
 
  def self.teardown
    begin
      $browser.quit
    rescue
      # we're getting "Connection Refused" errors here. Silently swallow them for now, until we can
      # figure out the problem
    end
  end
  
  def self.reset
    $browser.goto APP_BASE_URL
  end
end
