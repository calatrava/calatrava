exports = require 'spec_helper'

example = exports.example
stubView = exports.stubView

describe 'converter controller', ->
  beforeEach ->
    @changePage = jasmine.createSpy('page changer').andCallFake (targetPage) ->
      if @views[targetPage].boundEvents['pageOpened']?
        @views[targetPage].trigger 'pageOpened'
    @views =
      conversionForm: stubView.create('converterForm')
    @exchangeRateRepository = jasmine.createSpy "fake repository"

    example.converter.controller
      changePage: @changePage
      views: @views
      repository:
        exchangeRate: @exchangeRateRepository

  it 'should bind the convert event', ->
    expect(@views.conversionForm.boundEvents['convert']).not.toBeUndefined()

  describe 'converting', ->

    beforeEach ->
      @views.conversionForm.fieldContains 'in_currency', 'USD'
      @views.conversionForm.fieldContains 'out_currency', 'AUD'

    it 'should render the correctly converted amount', ->
      @views.conversionForm.fieldContains 'in_amount', 100
      @views.conversionForm.trigger 'convert'
      @exchangeRateRepository.mostRecentCall.args[0].ifSucceeded(.96)
      expect(@views.conversionForm.lastMessage()).toEqual
        out_amount: 96

    it 'should round-off amount to 2 decimal places', ->
      @views.conversionForm.fieldContains 'in_amount', 1
      @views.conversionForm.trigger 'convert'
      @exchangeRateRepository.mostRecentCall.args[0].ifSucceeded(.3663)
      expect(@views.conversionForm.lastMessage()).toEqual
        out_amount: .37

    it 'should confirm when amount is absent', ->
      calatrava.confirm = jasmine.createSpy("confirmation dialog")
      @views.conversionForm.fieldContains 'in_amount', ""
      @views.conversionForm.trigger 'convert'

      expect(calatrava.confirm).toHaveBeenCalled()

    it 'should consider amount as 1 if amount is absent and confirmation accepted', ->
      calatrava.confirm = jasmine.createSpy("confirmation dialog")
      @views.conversionForm.fieldContains 'in_amount', ""
      @views.conversionForm.trigger 'convert'
      calatrava.confirm.mostRecentCall.args[1](true)
      @exchangeRateRepository.mostRecentCall.args[0].ifSucceeded(.96)

      expect(@views.conversionForm.lastMessage()).toEqual
        out_amount: 0.96

