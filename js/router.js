var Router;

window.Router = Router = (function() {
  function Router() {}

  Router.prototype._storage = {};

  Router.prototype.initialize = function() {};

  Router.prototype.start = function() {
    this.initialize();
    this.go('index');
    return this;
  };

  Router.prototype.set = function(key, val) {
    if (val != null) {
      this._storage[key] = val;
    } else {
      this._storage[key] = null;
    }
    return this;
  };

  Router.prototype.get = function(key) {
    return this._storage[key];
  };

  Router.prototype.go = function(url) {
    var page, params, route;
    route = url.split('/');
    page = route.shift();
    params = route;
    if (this[page] != null) {
      return typeof this[page] === "function" ? this[page](params[0], params[1]) : void 0;
    } else {
      return this.index();
    }
  };

  return Router;

})();
