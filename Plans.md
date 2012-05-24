Calatrava will be a Ruby gem that you use to create projects. Running
`calatrava <app>` will create a directory for a new app.

This directory will contain the recommended directory tree, and a
Rakefile that uses the Calatrava build tasks.

The directory tree will contain the following directories:

* `kernel`: the shared logic re-used across all platforms.
* `shell`: the HTML UI that may be shared across many platforms.
* `ios`: a directory containing an Xcode project for the iOS app.
* `droid`: a directory containing the Android project.
* `web`: a directory containing a single-page JavaScript application
  built from the `kernel` and `shell`.
* `features`: a directory to put your cucumber features in.

The rake tasks will be responsible for building the kernel and shell,
and it's expected that these tasks will be used to build the other
applications.

