[![Build Status](https://travis-ci.org/calatrava/calatrava.png)](https://travis-ci.org/calatrava/calatrava)

# Dependencies

It should be as easy to get started with Calatrava as
possible. However, there are still a small number of dependencies that
need to be installed beforehand.

*Note*: Currently, Calatrava only supports fully-featured development
 on Macs. This will probably always be the case for iOS apps. Linux
 support for Android and Mobile Web is in progress. Windows is a
 little further off. Pull requests welcomed.

## Mac dependencies  

1. [rvm](http://rvm.io). Calatrava projects are configured to use
   `rvm` by default. You could use Calatrava without it, but you will
   then need to make sure you have Ruby 1.9.3 installed however you
   prefer.
   
2. [bundler](http://gembundler.com/). Install in either your `rvm`
   global gemset, or wherever else makes sense for your setup.

3. Xcode. You'll have to get this from the Mac App Store. Once
   installed, make sure you download and install the command line
   tools, and make sure you run `xcode-select`. Calatrava doesn't
   actually directly use Xcode except when building iOS apps, so you
   can use it on a non-Mac as long as you don't run the iOS build
   targets.

4. Android SDK. I recommend installing using
   [homebrew](http://mxcl.github.com/homebrew/) if you're on a
   Mac. But however you get hold of it, the `android` command is
   expected to be on the path.

5. [Node.js](http://nodejs.org/). Only used to run tests, not part of
   any production code. Again, if you're on a Mac I recommend
   installing using homebrew.

6. [ant](http://ant.apache.org/). Up until Mac OS X 10.9 Mavericks this
   was included. However, it has now been removed. It can be [installed with
   homebrew](http://superuser.com/questions/610157/how-do-i-install-ant-on-os-x-mavericks),
   however. Only required for Droid projects.
   
## Linux

*Note:* Support for Linux is limited to running the Android and Mobile
 Web builds. Please note the following restrictions:

* If you generate a new project using calatrava, the iOS part will not
  be generated.
* Only the `web:\*` and `droid:\*` and `kernel:\*` tasks will work.

Here are the dependencies for Linux:

1. [rvm](http://rvm.io). Calatrava projects are configured to use
   `rvm` by default. You could use Calatrava without it, but you will
   then need to make sure you have Ruby 1.9.3 installed however you
   prefer.
   
2. [bundler](http://gembundler.com/). Install in either your `rvm`
   global gemset, or wherever else makes sense for your setup.
   
4. [Android SDK](http://developer.android.com/sdk/index.html) &mdash;
   the `android` command is expected to be on the path.
   
5. [Node.js](http://nodejs.org/) and [NPM](https://npmjs.org/). Only
   used to run tests, not part of any production code.
   
6. [Apache2](http://httpd.apache.org/). Used for hosting the mobile
   web versions. Some flavours of Linux will not come with this
   shipped. On Ubuntu systems, this can be installed with the
   following command: `sudo apt-get install apache2` (from
   [this page](https://help.ubuntu.com/10.04/serverguide/httpd.html))

7. [ant](http://ant.apache.org/). You'll probably pick this up when you
   install the Android tools. Only required for Droid projects.

# Getting Started

Once you have the dependenices installed, there are just six simple
steps to creating and building your first Calatrava cross-platform
mobile app.

1. Install the Calatrava gem: `gem install calatrava`

2. Create your Calatrava project: `calatrava create
   <project-name>`

3. `cd <project-name>`. If you're using `rvm` you will be prompted to
   trust a new `.rvmrc`.
   
4. `bundle install`

5. `rake bootstrap`

6. To build and run the Mobile Web app: `rake web:apache:start`

   Then browse to [`http://localhost:8888`](http://localhost:8888) in
   your favourite browser.

7. To build and install the Android app: `rake droid:deploy`

   You will need to have an Android emulator running, or a device
   connected.
   
8. To build and run the iOS app open the Xcode workspace in the `ios`
   directory, and then build and run the target named after your
   project.

# Working with Calatrava while it's under Development

1. Clone this repo.

2. `cd` into the repo.

3. Run `bin/calatrava create <project-name> --dev`

The `--dev` switch will create a new project that refers to the
`calatrava` gem as a path on disk. This is much more convenient if
you're experimenting with Calatrava, or working on it.

