(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define([], function() {
    var Word, Words;
    Word = (function(_super) {
      __extends(Word, _super);

      function Word() {
        return Word.__super__.constructor.apply(this, arguments);
      }

      Word.prototype.idAttribute = 'key';

      Word.prototype.sync = function(method, model, options) {
        if (method === 'create') {
          console.log('creating word', model);
          return new Lawnchair({
            name: 'words',
            record: 'word'
          }, function() {
            return this.save(model.toJSON(), function(word) {
              console.log('created word', word);
              if (word != null) {
                return typeof options.success === "function" ? options.success(word) : void 0;
              } else {
                return typeof options.error === "function" ? options.error(model) : void 0;
              }
            });
          });
        }
      };

      return Word;

    })(Backbone.Model);
    Words = (function(_super) {
      __extends(Words, _super);

      function Words() {
        return Words.__super__.constructor.apply(this, arguments);
      }

      Words.prototype.model = Word;

      return Words;

    })(Backbone.Collection);
    return {
      model: Word,
      collection: Words
    };
  });

}).call(this);
