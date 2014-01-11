should = require 'should'
mocha = require 'mocha'
_ = require 'underscore'

describe "underscore trim mixin", ->
  it "should return a string without the trailing whitespace", ->
    _.mixin
      trim: (string) ->
        if _.last(string) is ' '
          _(_.initial(string)).trim()
        else
          string.join ''

    _("string   ").trim().should.eql "string"
