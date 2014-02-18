(function() {
  window.Tutor = Ember.Application.create();

  Tutor.ApplicationSerializer = DS.LSSerializer.extend();

  Tutor.ApplicationAdapter = DS.LSAdapter.extend({
    namespace: 'tutor-ember'
  });

  Tutor.Router.map(function() {
    this.route('home', {
      path: '/'
    });
    this.route('addWords');
    return this.resource('study', function() {
      this.route('index', {
        path: '/'
      });
      return this.route('words', {
        path: '/:type'
      });
    });
  });

  Tutor.HomeRoute = Ember.Route.extend({
    model: function() {
      return this.store.find('word');
    }
  });

  Tutor.AddWordsForm = Ember.View.extend({
    templateName: 'addWordsForm',
    store: (function() {
      return this.get('controller').get('store');
    }).property(),
    submit: function() {
      var def, record, type, word;
      type = this.get('dropdown').dropdown('get value');
      if (typeof type === 'string') {
        word = this.get('word');
        def = this.get('definition');
        if (Ember.isEmpty(word) || Ember.isEmpty(def)) {
          return Messenger().post({
            type: 'error',
            message: "Can't have blanks"
          });
        } else {
          record = this.get('store').createRecord('word', {
            type: type,
            word: word,
            definition: def
          });
          record.save();
          this.set('word', '');
          return this.set('definition', '');
        }
      }
    }
  });

  ({
    didInsertElement: function() {
      var dropdown;
      dropdown = $('.ui.selection.dropdown').dropdown();
      this.set('dropdown', dropdown);
      return $('.ui.form').form();
    }
  });

  Tutor.ChooseTypeForm = Ember.View.extend({
    didInsertElement: function() {
      var dropdown;
      dropdown = $('.ui.selection.dropdown').dropdown();
      return this.set('dropdown', dropdown);
    },
    "continue": function() {
      var type;
      type = this.get('dropdown').dropdown('get value');
      console.log(typeof type);
      if (typeof type !== 'string') {
        type = 'all';
      } else {
        console.log('it was a string');
      }
      console.log(type);
      return this.get('controller').transitionToRoute('study.words', type);
    }
  });

  Tutor.ChooseContinueBtn = Ember.View.extend({
    click: function() {
      return this.get('parentView')["continue"]();
    }
  });

  Tutor.StudyWordsController = Ember.ArrayController.extend({
    currentWord: (function() {
      return this.get('model').get('firstObject');
    }).property('model'),
    isWrong: false,
    actions: {
      check: function() {
        var answer, def, form;
        form = $('.ui.form').form();
        def = this.get('definition');
        answer = this.get('currentWord.definition');
        if (def === answer) {
          this.set('definition', '');
          this.set('isWrong', false);
          return this.showNext();
        } else {
          return this.set('isWrong', true);
        }
      }
    },
    showNext: function() {
      var newModel;
      newModel = this.get('model').without(this.get('currentWord'));
      this.set('model', newModel);
      if (newModel.get('length') === 0) {
        Messenger().post({
          type: '',
          message: 'No more words'
        });
        return this.transitionToRoute('home');
      } else {
        return this.set('currentWord', newModel.get('firstObject'));
      }
    }
  });

  Tutor.StudyWordsRoute = Ember.Route.extend({
    model: function(params) {
      var type;
      type = params.type;
      if (type === 'all') {
        return this.store.find('word');
      } else {
        return this.store.find('word', {
          type: type
        });
      }
    }
  });

  Tutor.Word = DS.Model.extend({
    type: DS.attr('string'),
    word: DS.attr('string'),
    definition: DS.attr('string')
  });

  Messenger.options = {
    extraClasses: 'messenger-fixed messenger-on-top',
    theme: 'ice'
  };

}).call(this);
