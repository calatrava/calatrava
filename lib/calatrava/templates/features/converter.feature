Feature: Converter
  As an international traveller
  I want to check if I am getting a good exchange rate
  So that I can haggle and get a better rate

  @web
  Scenario: Converting to Aussie dollars
    Given I have 100 USD
    When I check conversion rate to AUD
    Then the result should be greater than 100