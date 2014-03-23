(function() {
  var __slice = [].slice;

  define(['views', 'word'], function(Views, WordModule) {
    var Router, Words;
    Words = WordModule.collection;
    Router = (function() {
      function Router() {}

      Router.prototype.go = function() {
        var args, page;
        page = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        if (this[page] != null) {
          return typeof this[page] === "function" ? this[page](args[0], args[1]) : void 0;
        } else {
          return this.home();
        }
      };

      Router.prototype.home = function() {
        return this.render(new Views.home);
      };

      Router.prototype.addWords = function() {
        return this.render(new Views.addWords({
          collection: Tutor.words
        }));
      };

      Router.prototype.studyWords = function(words) {
        if (words != null) {
          return this.render(new Views.study({
            collection: words
          }));
        } else {
          return Tutor.lawnchair.all((function(_this) {
            return function(words) {
              words = (new Words(words)).shuffle();
              return _this.render(new Views.preStudy({
                collection: words
              }));
            };
          })(this));
        }
      };

      Router.prototype.edit = function() {
        return Tutor.lawnchair.all((function(_this) {
          return function(words) {
            words = new Words(words);
            return _this.render(new Views.editWords({
              collection: words
            }));
          };
        })(this));
      };

      Router.prototype.render = function(view) {
        return Tutor.container.show(view);
      };

      return Router;

    })();
    return function() {
      window.Tutor = new Marionette.Application;
      Tutor.addRegions({
        container: '#container'
      });
      Tutor.addInitializer(function(options) {
        this.router = new Router;
        return this.lawnchair = new Lawnchair({
          name: 'words',
          record: 'word'
        }, function() {
          return this.all(function(words) {
            return Tutor.words = new Words(words);
          });
        });
      });
      Tutor.on('initialize:after', function() {
        return this.router.go('home');
      });
      return Tutor.start();
    };
  });

}).call(this);
