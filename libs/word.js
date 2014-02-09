// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define([], function() {
    var Word, Words, _ref, _ref1;
    Word = (function(_super) {
      __extends(Word, _super);

      function Word() {
        _ref = Word.__super__.constructor.apply(this, arguments);
        return _ref;
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
              if (typeof err === "undefined" || err === null) {
                model.trigger('request', word);
              }
              if (typeof err !== "undefined" && err !== null) {
                options.error(word);
              }
              return options.success(word);
            });
          });
        }
      };

      return Word;

    })(Backbone.Model);
    Words = (function(_super) {
      __extends(Words, _super);

      function Words() {
        _ref1 = Words.__super__.constructor.apply(this, arguments);
        return _ref1;
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