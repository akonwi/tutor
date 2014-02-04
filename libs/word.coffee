define [], ->
  class Word extends Backbone.Model
    idAttribute: '_id'

  class Words extends Backbone.Collection
    model: Word

  return {
    model: Word
    collection: Words
  }
