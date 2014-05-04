window.Word = class Word extends Backbone.Model
  idAttribute: 'word'

  sync: (method, model, options) ->
    if (method is 'create') or (method is 'update')
      console.log "#{method} word", model
      Tutor.get('db').set model.toJSON(), (err) ->
        if err?
          options.error?(model)
        else
          options.success?(model)
    if method is 'delete'
      Tutor.get('db').remove model.get('id')

window.Words = class Words extends Backbone.Collection
  model: Word
