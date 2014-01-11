WordsModule = require './word'
Word = WordsModule.model
Words = WordsModule.collection

# alias for App.router inside of views
Backbone.View::router = -> App.router

module.exports =
  home: class HomeView extends Marionette.Layout
    template: Handlebars.compile $('#home-view').html()
    events:
      'click #add-words-button': 'addWords'
      'click #study-button': 'studyWords'

    addWords: (e) ->
      e.preventDefault()
      @router().go 'addWords'

    studyWords: (e) ->
      e.preventDefault()
      @router().go 'studyWords'

  addWords: class AddWordsView extends Marionette.Layout
    template: Handlebars.compile $('#add-words-view').html()

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
      # TODO: trim the value
      $.fn.form.settings.rules.empty = (value) ->
        not _.isEmpty _(value).trim()

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
          word.save()

  study: class StudyView extends Marionette.Layout
    template: Handlebars.compile $('#study-words-view').html()
    regions:
      title: '.teal.header'

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

      # TODO: What happens on successful submission

class TitleView extends Marionette.ItemView
  template: Handlebars.compile "{{word}}"
