should = require 'should'
Backbone = require 'backbone'
Datastore = require 'nedb'

####### Stuff #########################
class Word extends Backbone.Model
  idAttribute: '_id'

class Words extends Backbone.Collection
  model: Word

Backbone.sync = (method, model, options) ->
  method_map[method](model, options)

method_map =
  create: (model, options) ->
    console.log "creating model...", model.get('word')
    attributes = model.toJSON()
    db.insert attributes, (err, newModel) ->
      ## TODO: perhaps newModel should be an instance of Backbone.Model when sent
      #        with the 'request' trigger and callbacks
      model.trigger('request', model, err, options) if err?
      model.trigger('request', model, newModel, options)

      options.error?(newModel, err) if err?
      options.success?(newModel, err)

  ## success and error callbacks will be given the number replaced or error
  update: (model, options) ->
    console.log "updating model...", model
    attributes = model.toJSON()
    db.update(
      { _id: attributes._id },
      attributes,
      {},
      (err, numReplaced) ->
        ## Somehow in hell, numReplaced which is an integer, magically turns
        #  into a backbone model when I stuff it into the callback
        #  WHAT AM I MISSING HERE?
        options.error?(numReplaced) if err?
        options.success?(numReplaced) if numReplaced?
    )

  ## success and error callbacks will be given an error if it exists
  delete: (model, options) ->
    console.log "deleting model..."
    attributes = model.toJSON()
    db.remove {_id: attributes._id}, (err) ->
      if err? then options.error?(err) else options.success?()

  read: (model, options) ->
    console.log "fetching model from database..."
    db.findOne {_id: model.get('_id')}, (err, doc) ->
      options.error?(doc, err)
      options.success?(doc)

db = new Datastore()

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
