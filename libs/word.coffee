define [], ->
  class Word extends Backbone.Model
    idAttribute: 'key'
    sync: (method, model, options) ->
      if method is 'create'
        console.log 'creating word', model
        new Lawnchair name: 'words', record: 'word', ->
          @save model.toJSON(), (word) ->
            console.log 'created word', word
            model.trigger('request', word) unless err?
            options.error(word) if err?
            options.success(word)

  class Words extends Backbone.Collection
    model: Word

  return {
    model: Word
    collection: Words
  }
