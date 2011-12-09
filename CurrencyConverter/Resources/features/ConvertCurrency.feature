Feature: Convert Currency
  As a traveler
  I want to quickly convert currencies
  So that I can track my expenses easily

Scenario: Displaying the conversion result to two decimal places to the user
  Given I am using the Currency Converter app
  When I enter a value of 10 USD
  And I ask the app to do the conversion
  Then I should see "5.00" on the screen