## Override Backbone.sync for NeDB
#  This will essentially just write to the db directly
#  Because this is supposed to return a jqxhr, but we don't need that here
#  To avoid a switch statement, methods have been
#  mapped in the 'method_map' object
Backbone.sync = (method, model, options) ->
  method_map[method](model, options)

method_map =
  create: (model, options) ->
    attributes = model.toJSON()
    switch method
      when 'create'
        console.log "inside of sync, model is ", model
        db.insert attributes, (err, newModel) ->
          model.trigger('request', model, err, options) if err?
          model.trigger('request', model, newModel, options)

          options.success(newModel) if options.success?
          options.error(err) if options.error?
