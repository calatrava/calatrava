exports = require 'spec_helper'

example = exports.example
stubView = exports.stubView

describe 'converter controller', ->
  ajax = null
  changePage = null
  views = null

  beforeEach ->
    ajax = jasmine.createSpy("ajax requester")
    changePage = jasmine.createSpy('page changer').andCallFake (targetPage) ->
      if views[targetPage].boundEvents['pageOpened']?
        views[targetPage].trigger 'pageOpened'
    views =
      conversionForm: stubView.create('converterForm')

    subject = example.converter.controller
      changePage: changePage
      views: views
      ajax: ajax

  it 'should bind the convert event', ->
    expect(views.conversionForm.boundEvents['convert']).not.toBeUndefined()

  describe 'converting', ->

    beforeEach ->
      views.conversionForm.fieldContains 'in_currency', 'USD'
      views.conversionForm.fieldContains 'out_currency', 'AUD'
      views.conversionForm.fieldContains 'in_amount', 100
      views.conversionForm.trigger 'convert'

    it 'should render the correctly converted amount', ->
      expect(views.conversionForm.render).toHaveBeenCalledWith
        out_amount: 96
