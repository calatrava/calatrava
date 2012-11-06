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
* [Issue #15][i15]: Uncaught TypeError: Object #<Object> has no method
  'success'
  
Changes that will affect existing projects:
* Edited httpd conf template: `config/templates/httpd.conf.erb`
* Edited the single page Haml template: `web/app/views/index.haml`

## v0.5.0

* First public release

## Contributors:
* [Giles Alexander](https://github.com/gga)
* [Vivek Jain](https://github.com/vivekjain10)
* [Renaud Tircher](https://github.com/rtircher)

[i5]: https://github.com/calatrava/calatrava/issues/5
[i12]: https://github.com/calatrava/calatrava/issues/12
[i13]: https://github.com/calatrava/calatrava/issues/13
[i14]: https://github.com/calatrava/calatrava/issues/14
[i15]: https://github.com/calatrava/calatrava/issues/15
