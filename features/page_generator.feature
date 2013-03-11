Feature: Page generator

  In order to avoid repetative tasks and speed up my workflow
  As a cross-platform mobile developer
  I want to use Calatrava to generate placeholder page files

  Scenario: Create a page using the Standard template
    When I run `calatrava generate page simple`
    Then the exit status should be 0
    And  the following directories should exist:
      | shell              |
      | shell/pages        |
      | shell/pages/simple |
    And  the file "shell/pages/simple/simple.haml" should contain "%div#simple.page"
    And  the file "shell/pages/simple/page.simple.coffee" should contain "calatrava.pageView.simple"
