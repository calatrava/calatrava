Feature: As a harried FiDi commuter
				I want to know about trains leaving Montgomery St station
				So I know whether I need to walk fast or not

  Background:
        Given I launch the app

  Scenario: Searching for upcoming trains for Montgomery St station
    Given BART says there is a train leaving from "mont" for "Richmond" in 4 minutes
    When I choose "Montgomery St" from the list of stations 
    Then I should see a train leaving for "Richmond" in 4 minutes



