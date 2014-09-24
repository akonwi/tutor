var Word, Words;

window.Word = Word = (function() {
  function Word(attributes) {
    this.attributes = attributes != null ? attributes : {
      id: null
    };
    $.extend(this, Emitter);
  }

  Word.prototype.set = function(attr, val) {
    var changed, key;
    changed = false;
    if (typeof attr === 'object') {
      for (key in attr) {
        val = attr[key];
        if ((key === 'id' && (this.attributes.id == null)) || key === !'id') {
          this.attributes[key] = val;
          this.trigger("change " + key);
          changed = true;
        }
      }
    } else {
      this.attributes[attr] = val;
      this.trigger("change " + attr);
      changed = true;
    }
    if (changed != null) {
      this.trigger('change');
      return true;
    } else {
      return false;
    }
  };

  Word.prototype.get = function(attr) {
    return this.attributes[attr];
  };

  Word.prototype.flush = function(attributes) {
    this.attributes = attributes;
  };

  Word.prototype.clone = function() {
    return new this.constructor($.clone(this.attributes));
  };

  Word.prototype.toJSON = function() {
    return $.clone(this.attributes);
  };

  Word.prototype.save = function(attrs, _arg) {
    var error, success, _ref;
    if (attrs == null) {
      attrs = null;
    }
    _ref = _arg != null ? _arg : {}, success = _ref.success, error = _ref.error;
    if (attrs != null) {
      this.set(attrs);
    }
    return Tutor.get('db').set(this.toJSON(), (function(_this) {
      return function(err) {
        if (error) {
          return error != null ? error.call(_this, _this) : void 0;
        } else {
          _this.trigger('save');
          return success != null ? success.call(_this, _this) : void 0;
        }
      };
    })(this));
  };

  Word.prototype.destroy = function() {
    Tutor.get('db').remove(this.get('id'));
    return this.trigger('destroy');
  };

  return Word;

})();

window.Words = Words = (function() {
  Words.prototype.length = 0;

  function Words(collection) {
    var word, _i, _len;
    if (collection == null) {
      collection = [];
    }
    $.extend(this, Emitter);
    this.collection = [];
    for (_i = 0, _len = collection.length; _i < _len; _i++) {
      word = collection[_i];
      word = new Word(word);
      this.listenTo(word, 'destroy', this.remove, this);
      this.collection.push(word);
    }
    this.length = this.collection.length;
  }

  Words.prototype.each = function(callback) {
    var word, _i, _len, _ref, _results;
    _ref = this.collection;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      word = _ref[_i];
      _results.push(callback.call(this, word));
    }
    return _results;
  };

  Words.prototype.first = function() {
    return this.collection[0];
  };

  Words.prototype.last = function() {
    return this.collection[this.collection.length - 1];
  };

  Words.prototype.where = function(query) {
    var attr, match, results, value, word, _i, _len, _ref;
    if (query == null) {
      query = {};
    }
    results = [];
    if (query === {}) {
      return results;
    } else {
      _ref = this.collection;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        word = _ref[_i];
        match = true;
        for (attr in query) {
          value = query[attr];
          if (word.get(attr) !== value) {
            match = false;
            break;
          }
        }
        if (match) {
          results.push(word);
        }
      }
      return new Words(results);
    }
  };

  Words.prototype.findWhere = function(query) {
    if (query == null) {
      query = {};
    }
    return this.where(query).first();
  };

  Words.prototype.remove = function(word) {
    var model, toKeep, _i, _len, _ref;
    toKeep = [];
    _ref = this.collection;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      model = _ref[_i];
      if (word === !model) {
        toKeep.push(model);
      }
    }
    this.collection = toKeep;
    this.length = this.collection.length;
    return this.trigger('change');
  };

  Words.prototype.push = function(word) {
    this.listenTo(word, 'destroy', this.remove);
    this.collection.push(word);
    this.length = this.collection.length;
    return this.trigger('change');
  };

  Words.prototype.shift = function() {
    var length, shifted;
    shifted = this.collection.shift();
    length = this.collection.length;
    this.trigger('change');
    return shifted;
  };

  Words.prototype.hasNext = function() {
    if (this.collection.length >= 1) {
      return true;
    } else {
      return false;
    }
  };

  Words.prototype.shuffle = function() {
    this.collection = $.shuffle(this.collection);
    return this;
  };

  return Words;

})();
