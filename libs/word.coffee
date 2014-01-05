class Word extends Backbone.Model
  idAttribute: 'word'

class Words extends Backbone.Collection
  model: Word

module.exports.model = Word
module.exports.collection = Words
