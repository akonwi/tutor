WordsModule = require './word'
Word = WordsModule.model
Words = WordsModule.collection

# alias for App.router inside of views
Backbone.View::router = -> App.router

module.exports =
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
        type:
          identifier: 'type'
          rules: [
            type: 'empty'
            prompt: 'Need a type'
          ]
        word:
          identifier: 'word'
          rules: [
            {
              type: 'empty'
              prompt: "Can't have a blank entry"
            },
            {
              type: 'exists'
              prompt: "That word already exists"
            }
          ]
        definition:
          identifier: 'definition'
          rules: [
            type: 'empty'
            prompt: 'Need a definition'
          ]

      # Overriding the default 'empty' rule for form validation
      $.fn.form.settings.rules.empty = (value) ->
        not _.isEmpty value

      # adding an 'exists' rule
      view = this
      $.fn.form.settings.rules.exists = (value) ->
        exists = view.collection.findWhere(word: value)
        not exists?

      dropdown = @$el.find('.ui.selection.dropdown')
      dropdown.dropdown()

      # apply validation rules
      form = @$el.find('.ui.form')
      form.form(rules, inline: true, on: 'blur')

      # handle on success submission
      form.form 'setting',
        onSuccess: ->
          attr = {}
          attr.type = dropdown.dropdown 'get value'
          attr.word = form.form('get field', 'word').val()
          attr.definition = form.form('get field', 'definition').val()

          word = new Word(attr)
          word.save {},
            success: (model) ->
              form.form('get field', 'word').val ''
              form.form('get field', 'definition').val ''

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

      $dropdown = @$el.find('.ui.selection.dropdown')
      $dropdown.dropdown()
      $form = @$el.find('.ui.form')
      $form.form(rules, inline: true, on: 'submit')

      $form.form 'setting',
        onSuccess: =>
          word_type = $dropdown.dropdown 'get value'
          unless word_type is 'all'
            @collection = @collection.where(type: word_type)
          @router().go 'studyWords', @collection

  study: class StudyView extends Marionette.Layout
    template: Handlebars.compile $('#study-words-view').html()
    events:
      'click #studyWords': (e) -> @router().go 'studyWords'
      'click #addWords': (e) -> @router().go 'addWords'
    regions:
      title: '.teal.header'

    initialize: ->
      ## this model will be the model which will be quizzed on,
      #  it will change as user continues and upon change,
      #  the ui will change to reflect the new word
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
            },
            {
              type: "is[#{definition}]"
              prompt: "Sorry that's incorrect"
            }
          ]

      form = @$el.find('.ui.form')
      form.form(rules, inline: true, on: 'submit')

      ## If answer is correct, quiz on the next word by changing @model's attributes
      view = this
      form.form 'setting',
        onSuccess: ->
          if next_word = view.collection.shift()
            view.model.set(next_word.attributes)
            $('#definition-input').val ''
          else
            window.alert "there are no more words"
            view.router().go 'home'

class TitleView extends Marionette.ItemView
  template: Handlebars.compile "{{word}}"
