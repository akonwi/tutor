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

    App.prototype.initialize = function() {
      this.addRegions({
        container: '#container',
        sidebar: '#side-menu'
      });
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
      return this.regions.sidebar.sidebar().toggle();
    };

    App.prototype.home = function() {
      this.regions.sidebar.hide();
      return this.render(new Views.home);
    };

    App.prototype.addWords = function() {
      return this.render(new Views.addWords);
    };

    App.prototype.studyWords = function(words) {
      if (words != null) {
        return this.render(new Views.study({
          collection: words
        }));
      } else {
        return this.render(new Views.preStudy);
      }
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
      if (view === null) {
        return this.regions.sidebar.hide();
      } else {
        this.regions.sidebar.html(view);
        return this.regions.sidebar.show();
      }
    };

    return App;

  })(Cosmo.Router);
  return window.Tutor = new App().start();
});
