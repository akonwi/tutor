var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

$(document).ready(function() {
  var Tutor;
  Messenger.options = {
    extraClasses: 'messenger-fixed messenger-on-top',
    theme: 'ice'
  };
  Tutor = (function(_super) {
    __extends(Tutor, _super);

    function Tutor() {
      return Tutor.__super__.constructor.apply(this, arguments);
    }

    Tutor.prototype.initialize = function() {
      this.addRegions({
        container: '#container',
        sidebar: '#side-menu'
      });
      this.set('db', new Store);
      this.get('db').all((function(_this) {
        return function(words) {
          return _this.set('words', new Words(words));
        };
      })(this));
      return this.regions.sidebar.sidebar().toggle();
    };

    Tutor.prototype.home = function() {
      this.regions.sidebar.hide();
      return this.render(new Views.home);
    };

    Tutor.prototype.addWords = function() {
      return this.render(new Views.addWords);
    };

    Tutor.prototype.studyWords = function(words) {
      if (words != null) {
        return this.render(new Views.study({
          collection: words
        }));
      } else {
        return this.render(new Views.preStudy);
      }
    };

    Tutor.prototype.edit = function() {
      return this.get('db').all((function(_this) {
        return function(words) {
          if (words.length !== 0) {
            words = new Words(words);
            return _this.render(new Views.editWords({
              collection: words
            }));
          } else {
            return Messenger().post({
              message: "There are no words to edit",
              type: ''
            });
          }
        };
      })(this));
    };

    Tutor.prototype.menu = function(view) {
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

    return Tutor;

  })(Cosmo.Router);
  return window.Tutor = new Tutor().start();
});
