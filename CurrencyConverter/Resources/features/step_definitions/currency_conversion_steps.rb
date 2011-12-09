When /^I enter a value of (\d+|\d+\.\d+) ([^\s]+)$/ do |amount, currency|
  Device::CurrencyConversionScreen.enter_amount amount
end

When /^I ask the app to do the conversion$/ do
  Device::CurrencyConversionScreen.click_convert
end

Then /^I should see "([^\"]*)" on the screen$/ do |expected|
  Device::CurrencyConversionScreen.expect_result expected
end