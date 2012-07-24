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
      views.conversionForm.trigger 'convert'

    it 'should get the amount to convert', ->
      expect(views.conversionForm.get).toHaveBeenCalledWith('amount')
    it 'should get the starting currency', ->
      expect(views.conversionForm.get).toHaveBeenCalledWith('start_currency')
    it 'should get the ending currency', ->
      expect(views.conversionForm.get).toHaveBeenCalledWith('end_currency')
