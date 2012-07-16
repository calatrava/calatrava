# Dependencies

It should be as easy to get started with Calatrava as
possible. However, there are still a small number of dependencies that
need to be installed beforehand.

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

# Getting Started

Once you have the dependenices installed, there are just six simple
steps to creating and building your first Calatrava cross-platform
mobile app.

1. Install the Calatrava gem: `gem install calatrava`

2. Create your Calatrava project: `calatrava create
   &lt;project-name&gt;`

3. `cd &lt;project-name&gt;`

4. `rake bootstrap`

5. `rake configure:development`

5. `rake [droid|ios|web]:build CALATRAVA_ENV=development`

And you're away! Or at least, you should be.

# Working with Calatrava while it's under Development

1. Clone this repo.

2. `cd` into the repo.

3. Run `bin/calatrava create &lt;project-name&gt; --dev`

The `--dev` switch will create a new project that refers to the
`calatrava` gem as a path on disk. This is much more convenient if
you're experimenting with Calatrava, or working on it.
