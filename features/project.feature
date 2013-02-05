Feature: Projects

  In order to save money but still create the most awesome mobile app
  As a cross-platform mobile developer
  I want to use Calatrava to create a project

  Scenario: Create a project using the standard Calatrava template
    When I run `calatrava create simple`
    Then the exit status should be 0
    And  the following directories should exist:
      | simple          |
      | simple/config   |
      | simple/droid    |
      | simple/ios      |
      | simple/kernel   |
      | simple/shell    |
      | simple/web      |
    And  the file "simple/calatrava.yml" should contain "project_name: simple"

  Scenario Outline: Should allow app types to be excluded
    When I run `calatrava create simple --no-<app>`
    Then the exit status should be 0
    And  a directory named "simple/<app>" should not exist

    Examples:
     | app   |
     | ios   |
     | droid |
     | web   |

  @travis
  Scenario: Templates can have deeply nested directories and files
    Given the following directories exist:
      | nested         |
      | nested/dir     |
      | nested/dir/sub |
    And   the following files exist:
      | nested/sample          |
      | nested/.config         |
      | nested/dir/sub/sample2 |
    When  I run `calatrava create proj --template nested --no-droid --no-ios`
    Then  the following directories should exist:
      | proj         |
      | proj/dir     |
      | proj/dir/sub |
    And   the following files should exist:
      | proj/sample          |
      | proj/.config         |
      | proj/dir/sub/sample2 |

  @travis
  Scenario: Template files can themselves be templates
    Given a directory named "template"
    And   a file named "template/.tmpl.calatrava" with:
      """
      Sample {{ project_name }}
      """
    When  I run `calatrava create templatized --template template --no-droid --no-ios`
    Then  a file named "templatized/.tmpl" should exist
    And   the file "templatized/.tmpl" should contain "Sample templatized"
