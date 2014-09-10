var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

$(document).ready(function() {
  var App;
  Messenger.options = {
    extraClasses: 'messenger-fixed messenger-on-top',
    theme: 'ice'
  };
  App = (function(_super) {
    __extends(App, _super);

    function App() {
      return App.__super__.constructor.apply(this, arguments);
    }

    App.prototype.container = document.getElementById('container');

    App.prototype.initialize = function() {
      this.set('db', new Store);
      return this.get('db').all((function(_this) {
        return function(items) {
          var collection;
          collection = new Words(items);
          _this.set('words', collection);
          return collection.on('change', function(newCollection) {
            return _this.set('words', newCollection);
          });
        };
      })(this));
    };

    App.prototype.render = function(component) {
      return React.renderComponent(component, this.container);
    };

    App.prototype.home = function() {
      return this.render(new Views.Home);
    };

    App.prototype.addWords = function() {
      return this.render(new Views.AddWords);
    };

    App.prototype.preStudy = function() {
      return this.render(new Views.PreStudy);
    };

    App.prototype.study = function(type) {
      var collection;
      return collection = this.get('db').all((function(_this) {
        return function(words) {
          words = new Words(words);
          if (type === 'all') {

          } else {
            words = words.where({
              type: type
            });
          }
          return console.log(words);
        };
      })(this));
    };

    App.prototype.edit = function() {
      return this.get('db').all((function(_this) {
        return function(words) {
          if (words.length !== 0) {
            words = new Words(words);
            return _this.render(new Views.editWords(words));
          } else {
            return Messenger().post({
              message: "There are no words to edit",
              type: ''
            });
          }
        };
      })(this));
    };

    App.prototype.menu = function(view) {
      if (view == null) {
        view = null;
      }
    };

    return App;

  })(Cosmo.Router);
  return window.Tutor = new App().start();
});
