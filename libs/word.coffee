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
      if method is 'update'
        console.log 'updating word', model
        new Lawnchair name: 'words', record: 'word', ->
          @where "word.word === '#{model.get('word')}'", (words) ->
            words[0].definition = model.get('definition')
            @save words[0], (word) ->
              console.log 'updated word', word

  class Words extends Backbone.Collection
    model: Word

  return { model: Word, collection: Words }
