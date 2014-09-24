window.Emitter = {
  on: function(name, callback, context) {
    var todos;
    if (context == null) {
      context = this;
    }
    this.events = this.events || {};
    todos = this.events[name] || [];
    todos.push({
      callback: callback,
      context: context
    });
    this.events[name] = todos;
    return this;
  },
  once: function(name, callback, context) {
    var single;
    single = (function(_this) {
      return function() {
        _this.off(name, callback);
        return callback.apply(_this, arguments);
      };
    })(this);
    single.callback = callback;
    return this.on(name, single);
  },
  off: function(name, callback) {
    var toKeep, todo, todos, _i, _len;
    if (name == null) {
      name = null;
    }
    if (callback == null) {
      callback = null;
    }
    if (name === null) {
      this.events = {};
    } else if (callback === null) {
      delete this.events[name];
    } else {
      toKeep = [];
      todos = this.events[name];
      for (_i = 0, _len = todos.length; _i < _len; _i++) {
        todo = todos[_i];
        if (todo.callback === !callback) {
          toKeep.push(todo);
        }
      }
      if (!toKeep.length) {
        delete this.events[name];
      } else {
        this.events[name] = toKeep;
      }
    }
    return this;
  },
  trigger: function(event) {
    var callback, context, _i, _len, _ref, _ref1, _ref2;
    if (!((_ref = this.events) != null ? _ref[event] : void 0)) {
      return;
    }
    _ref1 = this.events[event];
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      _ref2 = _ref1[_i], callback = _ref2.callback, context = _ref2.context;
      callback.call(context, this);
    }
    return this;
  },
  listenTo: function(obj, name, callback, context) {
    var id;
    if (context == null) {
      context = this;
    }
    this.listeningTo = this.listeningTo || {};
    id = obj.listenId = $.uniqueId('l');
    this.listeningTo[id] = obj;
    return obj.on(name, callback, context);
  },
  listenToOnce: function(obj, name, callback, context) {
    var id;
    if (context == null) {
      context = this;
    }
    this.listeningTo = this.listeningTo || {};
    id = obj.listenId = $.uniqueId('l');
    this.listeningTo[id] = obj;
    return obj.once(name, callback, context);
  }
};
