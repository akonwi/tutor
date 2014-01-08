## Override Backbone.sync for NeDB
#  This will essentially just write to the db directly
#  Because this is supposed to return a jqxhr, but we don't need that here
#  To avoid a switch statement, methods have been
#  mapped in the 'method_map' object
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
