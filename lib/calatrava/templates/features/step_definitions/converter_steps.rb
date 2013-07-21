Before do
  @driver = Selenium::WebDriver.for :firefox
end

After do
  @driver.quit
end

Given(/^I have (\d+) (.*)$/) do |amount, in_currency|
  @driver.get "http://localhost:8888"
  in_currency_selector = Selenium::WebDriver::Support::Select.new(@driver.find_element :id => "in_currency")
  in_currency_selector.select_by :value, in_currency
  in_amount = @driver.find_element :id => "in_amount"
  in_amount.clear
  in_amount.send_keys amount
end

When(/^I check conversion rate to (.*)$/) do |out_currency|
  out_currency_selector = Selenium::WebDriver::Support::Select.new(@driver.find_element :id => "out_currency")
  out_currency_selector.select_by :value, out_currency
  convert_button = @driver.find_element :id => "convert"
  convert_button.click
end

Then(/^the result should be greater than (\d+)$/) do |amount|
  wait = Selenium::WebDriver::Wait.new(:timeout => 3) # seconds
  wait.until { @driver.find_element(:id => "out_amount").attribute("value").to_f > 0 }
  @driver.find_element(:id => "out_amount").attribute("value").to_f.should > amount.to_f
end
