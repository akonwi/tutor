should = require 'should'
Backbone = require 'backbone'
Datastore = require 'nedb'
require('backbone.nedb')(Backbone)

####### Stuff #########################
class Word extends Backbone.Model
  idAttribute: '_id'

global.db = new Datastore()

clearDB = (done) ->
  db.remove {}, {multi: true}, (err) ->
    console.log 'cleared it'
    done()

describe 'Backbone.sync', ->
  attrs =
    word: 'manger'
    definition: 'to eat'

  beforeEach (done) ->
    clearDB(done)

  it "has a working 'create' method", ->
    word = new Word(attrs)
    word.save()
    db.findOne {}, (err, doc) ->
      doc.word.should.eql word.get('word')

  it "has a working 'update' method", ->
    word = new Word(attrs)
    word.save {}, success: (model, err) ->
      word.save {word: 'baller'}, success: (model, err) ->
        db.findOne {}, (err, doc) ->
          doc.word.should.eql 'baller'

  it "has a working 'delete' method", ->
    word = new Word(attrs)
    word.save {}, success: ->
      word.destroy success: ->
        db.findOne {}, (err, doc) ->
          should.equal doc, null

  it "has a working 'get' method", ->
    word = new Word(attrs)
    word.save {}, success: (model, err) ->
      model.fetch success: (model, err) ->
        model.should.be.an.instanceOf(Word)
        model.get('word').should.eql word.get('word')
