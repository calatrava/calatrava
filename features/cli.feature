Feature: Command line interface

  In order to create cross platform mobile apps
  As a mobile developer
  I want an easy to use command line tool

  Scenario: Command-line validations
    When I run `calatrava create`
    Then the output should contain "was called with no arguments"
    And  the output should contain "calatrava create <project-name>"
    When I run `calatrava create project --template nonexistentdirectory`
    Then the output should contain "template must exist"
    Given an empty file named "alt-template-file"
    When I run `calatrava create project --template alt-template-file`
    Then the output should contain "template must be a directory"

  Scenario: Android command-line parameters
    When I run `calatrava create droid_test --android-api 17`
    Then the exit status should be 0
    And  a file named "droid_test/droid/droid_test/project.properties" should exist
    And  the file "droid_test/droid/droid_test/project.properties" should contain:
    """
    target=android-17
    """
