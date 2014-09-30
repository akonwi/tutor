var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

document.addEventListener('DOMContentLoaded', function() {
  var App, URLS;
  URLS = {
    home: {
      route: 'index',
      text: 'Home'
    },
    study: {
      route: 'preStudy',
      text: 'Study'
    },
    edit: {
      route: 'editWords',
      text: 'Edit'
    },
    add: {
      route: 'addWords',
      text: 'Add'
    }
  };
  App = (function(_super) {
    __extends(App, _super);

    function App() {
      return App.__super__.constructor.apply(this, arguments);
    }

    App.prototype.container = document.getElementById('container');

    App.prototype.nav = document.getElementsByTagName('nav')[0];

    App.prototype.messageBox = document.getElementById('message-box');

    App.prototype.initialize = function() {
      _.extend(this, Emitter);
      this.set('db', new Store);
      this.get('db').all((function(_this) {
        return function(items) {
          var collection;
          collection = new Words(items);
          _this.set('words', collection);
          return collection.on('change', function(newCollection) {
            return _this.set('words', newCollection);
          });
        };
      })(this));
      React.renderComponent(new Views.NavBar({
        app: this
      }), this.nav);
      return React.renderComponent(new Views.Message({
        app: this
      }), this.messageBox);
    };

    App.prototype.render = function(component) {
      return React.renderComponent(component, this.container);
    };

    App.prototype.index = function() {
      this.render(new Views.Home);
      return this.trigger('change:menu', []);
    };

    App.prototype.addWords = function() {
      this.render(new Views.AddWords);
      return this.trigger('change:menu', [URLS.home, URLS.study, URLS.edit]);
    };

    App.prototype.preStudy = function() {
      this.render(new Views.PreStudy);
      return this.trigger('change:menu', [URLS.home, URLS.add, URLS.edit]);
    };

    App.prototype.study = function(type) {
      return this.get('db').all((function(_this) {
        return function(words) {
          words = new Words(words);
          if (type !== 'all') {
            words = words.where({
              type: type
            });
          }
          if (words.length === 0) {
            _this.index();
            return _this.trigger('message', 'No words to study');
          } else {
            _this.render(new Views.Study({
              collection: words.shuffle()
            }));
            return _this.trigger('change:menu', [URLS.home, URLS.add, URLS.edit]);
          }
        };
      })(this));
    };

    App.prototype.editWords = function() {
      return this.get('db').all((function(_this) {
        return function(words) {
          if (words.length !== 0) {
            words = new Words(words);
            _this.render(new Views.EditWords({
              collection: words
            }));
            return _this.trigger('change:menu', [URLS.home, URLS.add, URLS.study]);
          } else {

          }
        };
      })(this));
    };

    return App;

  })(Router);
  return window.Tutor = new App().start();
});
