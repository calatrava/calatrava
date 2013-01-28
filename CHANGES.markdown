## v0.6.4

Minor improvements:
* The `stubView` for stubbing pages when testing controllers now
  provides more direct access to the last render view message.

Bugs fixed:
* [Issue #28][i28]: Support Linux for creating projects and running
  the build.
* [Issue #35][i35]: Allow app specific environment keys.
* [Issue #31][i31]: Working with image assets will break the
  web:apache:start task. Now creates the `images` output directory as
  required.
* [Issue #26][i26]: Empty JS strings passed to JS functions are not
  escaped properly.
* [iOS Issue #3][ios-i3]: Prevent app from crashing when invoking
  plugin callback.
* [Issue #34][i34]: [web] Custom headers are not propagated to the
  ajax request.
* [Issue #32][i32]: calatrava.bridge.request() seems to require an
  optional "body" under iOS. One of `contentType` or `customHeaders`
  was also required, this too has been fixed.
* [Issue #39][i39]: [ios] Network activity spinner
* [Issue #40][i40]: calatrava.bridge.request() seems to require a
  "failure" callback in the browser, although documented as "optional"
* [Issue #42][i42]: Fixes the MobileWeb app loading issue. Pages were
  hidden by default, but the `show` and `hide` implementations for the
  converter page were incomplete.
* [Issue #43][i43]: Close the load_file.txt reader after loading
  files, on Android.

## v0.6.3

Bugs fixed:
* [Issue #22][i22] and [Issue #23][i23]: Support `*.scss` files as
  well as `*.sass` files.
* [Issue #24][i24]: Create the stylesheet output directories as part
  of the build process.
* [Issue #25][i25]: Recreate the `load_file.txt` when the feature
  manifest changes.
* iOS was correctly dispatching timer firings back to the controller
  code.

## v0.6.2

* Moving to a more recent version of the `xcodeproj` gem caused a
  conflict with Frank that needed to be resolved.

## v0.6.1

* iOS was not correctly loading HTML UIs. Fixing this also required
  re-working the project creation.

## v0.6.0

* Added
[plugin support](https://github.com/calatrava/calatrava/wiki/Plugins)
* Added an alert plugin implementation:
  `web/app/source/alert.web.coffee`,
  `droid/test/src/com/calatrava/bridge/AlertPlugin.java` and
  `ios/Pods/calatrava/calatrava-ios/Bridge/AlertPlugin.m`.
* Substantial re-writing of the build tasks. Should largely not be
  externally visible, except there are a lot less tasks now.
  
Bugs fixed:
* [Issue #5][i5]: Creates the droid build with default name of the
  project as 'test' instead of the project name
* [Issue #12][i12]: Failing AJAX - Typo in calatrava.inbound
* [Issue #13][i13]: Problem Building on Xcode (4.5.1) - Can't Find
  Bundler
* [Issue #14][i14]: Cosmetic: ios/public misplaced during calatrava
  create
* [Issue #15][i15]: Uncaught TypeError: Object #&lt;Object&gt; has no
  method 'success'
  
Changes that will affect existing projects:
* Edited httpd conf template: `config/templates/httpd.conf.erb`
* Edited the single page Haml template: `web/app/views/index.haml`

## v0.5.0

* First public release

## Contributors:
* [Giles Alexander](https://github.com/gga)
* [Pete Hodgson](https://github.com/moredip)
* [Vivek Jain](https://github.com/vivekjain10)
* [Renaud Tircher](https://github.com/rtircher)
* [Marcin Kwiatkowski](https://github.com/marcinkwiatkowski)
* [Pat Kua](https://github.com/thekua)
* [Maria Gomez](https://github.com/mariagomez)
* [Kalyan Akella](https://github.com/KalyanAkella)

[i5]: https://github.com/calatrava/calatrava/issues/5
[i12]: https://github.com/calatrava/calatrava/issues/12
[i13]: https://github.com/calatrava/calatrava/issues/13
[i14]: https://github.com/calatrava/calatrava/issues/14
[i15]: https://github.com/calatrava/calatrava/issues/15
[i22]: https://github.com/calatrava/calatrava/issues/22
[i23]: https://github.com/calatrava/calatrava/issues/23
[i24]: https://github.com/calatrava/calatrava/issues/24
[i25]: https://github.com/calatrava/calatrava/issues/25
[i28]: https://github.com/calatrava/calatrava/pull/28
[i35]: https://github.com/calatrava/calatrava/pull/35
[i31]: https://github.com/calatrava/calatrava/issues/31
[i26]: https://github.com/calatrava/calatrava/issues/26
[ios-i3]: https://github.com/calatrava/calatrava-ios/pull/3
[i34]: https://github.com/calatrava/calatrava/issues/34
[i32]: https://github.com/calatrava/calatrava/issues/32
[i39]: https://github.com/calatrava/calatrava/issues/39
[i40]: https://github.com/calatrava/calatrava/issues/40
[i42]: https://github.com/calatrava/calatrava/issues/42
[i43]: https://github.com/calatrava/calatrava/issues/43
