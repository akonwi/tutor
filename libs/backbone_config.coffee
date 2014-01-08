## Override Backbone.sync for NeDB
#  This will essentially just write to the db directly
#  Because this is supposed to return a jqxhr, but we don't need that here
#  To avoid a switch statement, methods have been
#  mapped in the 'method_map' object
Backbone.sync = (method, model, options) ->
  method_map[method](model, options)

method_map =
  create: (model, options) ->
    console.log "creating model..."
    attributes = model.toJSON()
    db.insert attributes, (err, newModel) ->
      model.trigger('request', model, err, options) if err?
      model.trigger('request', model, newModel, options)

      options.success?(newModel) if newModel?
      options.error?(err) if err?

  update: (model, options) ->
    console.log "updating model..."
    attributes = model.toJSON()
    db.update(
      { _id: attributes._id },
      attributes,
      {},
      (err, numReplaced) ->
        ## Somehow in hell, numReplaced which is an integer, magically turns
        #  into a backbone model when I stuff it into the callback
        #  WHAT AM I MISSING HERE?
        options.success?(numReplaced)
        options.error?(numReplaced)
    )

