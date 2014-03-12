define [], ->
  class Word extends Backbone.Model
    idAttribute: 'key'
    sync: (method, model, options) ->
      if method is 'create'
        console.log 'creating word', model
        new Lawnchair name: 'words', record: 'word', ->
          @save model.toJSON(), (word) ->
            console.log 'created word', word
            if word?
              options.success?(word)
            else
              options.error?(model)

  class Words extends Backbone.Collection
    model: Word

  return { model: Word, collection: Words }
