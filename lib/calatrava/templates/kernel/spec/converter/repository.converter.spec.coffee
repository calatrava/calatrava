exports = require 'spec_helper'

example = exports.example

describe 'converter repository', ->

  beforeEach ->
    @ajax = jasmine.createSpy "ajax requester"
    @onSuccess = jasmine.createSpy "success callback"
    @onFailure = jasmine.createSpy "failure callback"
    example.converter.apiEndpoint = "//endpoint"
    example.converter.repository(@ajax).exchangeRate
      from: "USD"
      to: "INR"
      ifSucceeded: @onSuccess
      elseFailed: @onFailure

  it 'should call appropriate API for exchange rate', ->
    expect(@ajax.mostRecentCall.args[0].url).toEqual "//endpoint/currency?from=USD&to=INR"

  it 'should call success callback with rate when request is successful', ->
    @ajax.mostRecentCall.args[0].success "{\"rate\": 55}"
    expect(@onSuccess).toHaveBeenCalledWith 55

  it 'should call failure callback when request fails', ->
    @ajax.mostRecentCall.args[0].failure "failure response"
    expect(@onFailure).toHaveBeenCalledWith("failure response")
