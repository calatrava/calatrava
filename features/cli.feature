Feature: Command line interface

  In order to create cross platform mobile apps
  As a mobile developer
  I want an easy to use command line tool

  Scenario: Command-line validations
    When I run `calatrava create`
    Then the output should contain "calatrava create requires at least 1 argument"
    When I run `calatrava create project --template nonexistentdirectory`
    Then the output should contain "template must exist"
    Given an empty file named "alt-template-file"
    When I run `calatrava create project --template alt-template-file`
    Then the output should contain "template must be a directory"
