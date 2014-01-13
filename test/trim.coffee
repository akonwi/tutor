should = require 'should'
mocha = require 'mocha'
_ = require 'underscore'

describe "underscore trim mixin", ->
  it "should return a string without the trailing whitespace", ->
    _.trim = (string) ->
      unless _.isEmpty string
        if _.last(string) is ' ' then @trim(_.initial(string)) else string.join ''
      else
        if _.isString(string) then string else ''

    _.trim("string   ").should.eql "string"
    _.trim("").should.eql ""
    _.trim(" ").should.eql ''
