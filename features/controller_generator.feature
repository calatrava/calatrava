Feature: Controller generator

  In order to avoid repetative tasks and speed up my workflow
  As a cross-platform mobile developer
  I want to use Calatrava to generate placeholder controller files

  Scenario: Create a controller using the Standard template
    When I run `calatrava generate controller simple`
    Then the exit status should be 0
    And  the following directories should exist:
      | kernel            |
      | kernel/app        |
      | kernel/app/simple |
    And  the file "kernel/app/simple/init.simple.coffee" should contain "example.simple.start"
    And  the file "kernel/app/simple/controller.simple.coffee" should contain "example.simple.controller"

  Scenario: Create a controller using a namespace
    When I run `calatrava generate controller simple --namespace mynamespace`
    Then the exit status should be 0
    And  the following directories should exist:
      | kernel            |
      | kernel/app        |
      | kernel/app/simple |
    And  the file "kernel/app/simple/init.simple.coffee" should contain "mynamespace.simple.start"
    And  the file "kernel/app/simple/controller.simple.coffee" should contain "mynamespace.simple.controller"