define ['word'], (WordsModule) ->
  Word = WordsModule.model
  Words = WordsModule.collection

  Backbone.View::router = -> Tutor.router

  to_return =
    home: class HomeView extends Marionette.Layout
      template: Handlebars.compile $('#home-view').html()
      events:
        'click #add-words-button': (e) -> @router().go 'addWords'
        'click #study-button': (e) -> @router().go 'studyWords'

    addWords: class AddWordsView extends Marionette.Layout
      template: Handlebars.compile $('#add-words-view').html()
      events:
        'click #home': (e) -> @router().go 'home'
        'click #studyWords': (e) -> @router().go 'studyWords'

      render: ->
        @$el.html @template()
        @initialize_form()
        this

      initialize_form: ->
        rules =
          word:
            identifier: 'word'
            rules: [
              {
                type: 'empty',
                prompt: "Can't have a blank entry"
              }, {
                type: 'exists'
                prompt: 'That word already exists'
              }
            ]
          definition:
            identifier: 'definition'
            rules: [
              type: 'empty'
              prompt: 'Need a definition'
            ]

        # override semantic validation rule
        $.fn.form.settings.rules.empty = (value) ->
          not _.isEmpty(value)

        #view = this
        $.fn.form.settings.rules.exists = (value) =>
          exists = @collection.findWhere(word: value)
          not exists?

        $dropdown = @$el.find('.ui.selection.dropdown').dropdown()
        $form = @$el.find('.ui.form')
        $form.form(rules,
          inline: true
          on: 'submit'
        )
        $form.form 'setting',
          onSuccess: ->
            attr = {}
            attr.type = $dropdown.dropdown('get value')
            if _.isString(attr.type)
              attr.word = $form.form('get field', 'word').val()
              attr.definition = $form.form('get field', 'definition').val()
              word = new Word(attr)
              word.save {},
                success: (model) ->
                  $form.form('get field', 'word').val()
                  $form.form('get field', 'definition').val()
                  $('#word-input').focus()
            else
              Messenger().error 'Please choose a type'

    preStudy: class ChooseWordsView extends Marionette.Layout
      template: Handlebars.compile $('#choose-words-view').html()
      events:
        'click #home': (e) -> @router().go 'home'

      render: ->
        @$el.html @template()
        @initialize_form()
        this

      initialize_form: ->
        rules =
          type:
            identifier: 'type'
            rules: [
              type: 'empty'
              prompt: 'Need a type'
            ]

        $dropdown = @$el.find('.ui.selection.dropdown').dropdown()
        $form = @$el.find('.ui.form')
        $form.form(rules, on: 'submit')
        $form.form 'setting',
          onSuccess: =>
            word_type = $dropdown.dropdown('get value')
            words = @collection
            if word_type is not 'all'
              words = new Words(words).where(type: word_type)
            @router().go 'studyWords', words
          onFailure: ->
            Messenger().error 'Please choose which type of words to study'

    study: class StudyView extends Marionette.Layout
      template: Handlebars.compile $('#study-words-view').html()
      events:
        'click #studyWords': (e) -> @router().go 'studyWords'
        'click #addWords': (e) -> @router().go 'addWords'

      regions:
        title: '.teal.header'

      initialize: ->
        @model = @collection.shift().clone()
        @model.on 'change', (model) =>
          @title.show new TitleView(model: model)
          @initialize_form()

      render: ->
        @$el.html @template()
        @title.show new TitleView(model: @model)
        @initialize_form()
        this

      initialize_form: ->
        definition = @model.get('definition')
        rules =
          definition:
            identifier: 'definition'
            rules: [
              {
                type: 'empty'
                prompt: 'Give it a try'
              }, {
                type: "is[" + definition + "]"
                prompt: "Sorry that's incorrect"
              }
            ]

        $form = @$el.find('.ui.form').form(rules, inline: true, on: 'submit')
        #view = this
        $form.form 'setting',
          onSuccess: =>
            @showNext()

      showNext: ->
        if next_word = @collection.shift()
          @model.set(next_word.attributes)
          $('#definition-input').val ''
        else
          Messenger.error 'There are no more words'
          @router().go 'home'

  class TitleView extends Marionette.ItemView
    template: Handlebars.compile "{{word}}"
