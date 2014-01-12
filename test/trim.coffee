should = require 'should'
mocha = require 'mocha'
_ = require 'underscore'

describe "underscore trim mixin", ->
  it "should return a string without the trailing whitespace", ->
    _.mixin
      trim: (string) ->
        unless _.isEmpty string
          if _.last(string) is ' '
            @trim _.initial(string)
          else
            string.join ''
        else
          string

    _("string   ").trim().should.eql "string"
    _("").trim().should.eql ""
