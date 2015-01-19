var Closet, Store;

window.Closet = Closet = (function() {
  Closet.prototype._isChromeApp = false;

  function Closet(name) {
    var _ref;
    if (((_ref = chrome.storage) != null ? _ref.local : void 0) != null) {
      this._isChromeApp = true;
      this._storage = chrome.storage.local;
      this._runtime = chrome.runtime;
    } else {
      if (!name) {
        throw new Error('Need a name for closet');
      }
      this.name = name;
      this._storage = localStorage;
      if (!this._storage.getItem(name)) {
        this._storage.setItem(name, '{}');
      }
    }
  }

  Closet.prototype._toJSON = function(obj) {
    return JSON.stringify(obj);
  };

  Closet.prototype._fromJSON = function(str) {
    return JSON.parse(str);
  };

  Closet.prototype._local = function(toSave) {
    if (toSave == null) {
      toSave = null;
    }
    if (toSave != null) {
      return this._storage.setItem(this.name, this._toJSON(toSave));
    } else {
      return this._fromJSON(this._storage.getItem(this.name));
    }
  };

  Closet.prototype.set = function(obj, func) {
    var id, local, toSave;
    if (this._isChromeApp) {
      (toSave = {})[obj.id] = obj;
      return this._storage.set(toSave, (function(_this) {
        return function() {
          var err;
          if (func != null) {
            if (err = _this._runtime.lastError) {
              return func.call(_this, err);
            } else {
              return func.call(_this);
            }
          }
        };
      })(this));
    } else {
      id = obj.id;
      delete obj.id;
      local = this._local();
      local[id] = obj;
      this._local(local);
      if (func != null) {
        return func.call(this);
      }
    }
  };

  Closet.prototype.get = function(key, func) {
    var results;
    if (this._isChromeApp) {
      return this._storage.get(key, function(results) {
        return func.call(this, _.toArray(results));
      });
    } else {
      results = this._local()[key];
      if (func != null) {
        return func.call(this, results);
      } else {
        return results;
      }
    }
  };

  Closet.prototype.all = function(func) {
    var all;
    if (this._isChromeApp) {
      return this._storage.get(null, function(items) {
        return func.call(this, _.toArray(items));
      });
    } else {
      all = _.toArray(this._local);
      if (func) {
        return func.call(this, all);
      } else {
        return all;
      }
    }
  };

  Closet.prototype.remove = function(key, func) {
    var l;
    if (this._isChromeApp) {
      return this._storage.remove(key, function() {
        var err;
        if (func != null) {
          if (err = this.runtime.lastError) {
            return func.call(this, err);
          } else {
            return func.call(this);
          }
        }
      });
    } else {
      l = this._local();
      delete l[key];
      return this._local(l);
    }
  };

  return Closet;

})();

window.Store = Store = (function() {
  function Store() {}

  Store.prototype.set = function(obj, func) {
    var toSave;
    (toSave = {})[obj.id] = obj;
    console.log("to save", toSave);
    return storage.set(toSave, (function(_this) {
      return function() {
        var error;
        if (func != null) {
          if (error = runtime.lastError) {
            return func.call(_this, error);
          } else {
            return func.call(_this);
          }
        }
      };
    })(this));
  };

  Store.prototype.get = function(key, func) {
    return storage.get(key, function(results) {
      return func.call(this, _.toArray(results));
    });
  };

  Store.prototype.getOne = function(key, func) {
    return this.get(key, function(results) {
      return func.call(this, results[0]);
    });
  };

  Store.prototype.all = function(func) {
    return storage.get(null, function(items) {
      return func.call(this, _.toArray(items));
    });
  };

  Store.prototype.remove = function(key, func) {
    return storage.remove(key, function() {
      var error;
      if (func != null) {
        if (error = runtime.lastError) {
          return func.call(this, error);
        } else {
          return func.call(this);
        }
      }
    });
  };

  return Store;

})();
