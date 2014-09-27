var Store, runtime, storage;

storage = chrome.storage.local;

runtime = chrome.runtime;

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
