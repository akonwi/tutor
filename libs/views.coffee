View::go = (page, args...) ->
  switch args.length
    when 1 then Tutor.go page, args[0]
    when 2 then Tutor.go page, args[0], args[1]
    else Tutor.go page

View::isString = (obj) ->
  toString.call(obj).indexOf('String') isnt -1

View::capitalize = (word) ->
  word[0].toUpperCase() + word[1..-1].toLowerCase()

window.Views =
  home: class HomeView extends View
    @content: ->
      @div id: 'content', =>
        @div class: 'ui huge center aligned header', 'Tutor'
        @div class: 'ui large center aligned header', "Let's Study!"
        @div class: 'ui center aligned three column grid', =>
          @div class: 'row', =>
            @div id: 'study-button',
              class: 'ui button',
              click: 'study',
              'Study'
          @div class: 'row', =>
            @div id: 'add-words-button',
              class: 'ui button',
              click: 'add'
              'Add words'
          @div class: 'row', =>
            @div id: 'edit-words-button',
              class: 'ui button',
              click: 'edit',
              'Edit Words'

    study: -> @go 'studyWords'
    add: -> @go 'addWords'
    edit: -> @go 'edit'

  addWords: class AddWordsView extends View
    @content: ->
      @div id: 'content', =>
        @div class: 'ui huge center aligned header', 'Add Words'
        @div class: 'ui center aligned three column grid', =>
          @div class: 'column'
          @div class: 'column', =>
            @subview 'addWordsForm', new AddWordsForm
          @div class: 'column'

  preStudy: class ChooseWordsView extends View
    @content: ->
      @div id: 'content', =>
        @div class: 'ui huge center aligned header', 'Study'
        @div class: 'ui center aligned three column grid', =>
          @div class: 'column'
          @div class: 'column', =>
            @div class: 'ui teal medium center aligned header', 'Study by type'
            @div class: 'ui form segment', =>
              @subview 'typeDropdown', new TypeDropdown
              @div class: 'ui green submit button', 'Continue'
          @div class: 'column'

    initialize: ->
      # first add 'All' option to dropdown
      @typeDropdown.find('.menu').prepend $$ ->
        @div class: 'item', 'data-value': 'all', 'All'

      rules =
        type:
          identifier: 'type'
          rules: [
            type: 'empty'
            prompt: 'Need a type'
          ]

      $dropdown = @find('.ui.selection.dropdown').dropdown()
      $form = @find('.ui.form')
      $form.form(rules, on: 'submit')
        .form 'setting',
          onSuccess: =>
            word_type = $dropdown.dropdown('get value')
            Tutor.get('lawnchair').all (words) =>
              collection = new Words(words)
              unless word_type is 'all'
                collection = new Words(words).where(type: word_type)
              @go 'studyWords', collection.shuffle()
          onFailure: ->
            Messenger().post
              message: 'Please choose which type of words to study'
              type: ''

  study: class StudyView extends View
    @content: ->
      @div id: 'content', =>
        @div class: 'ui huge center aligned header', 'Study'
        @div class: 'ui center aligned three column grid', =>
          @div class: 'column'
          @div class: 'column', =>
            @subview 'wordTitle', new WordTitle
            @div class: 'ui form segment', =>
              @div class: 'field', =>
                @div class: 'ui input', =>
                  @input id: 'definition-input',
                    type: 'text',
                    name: 'definition',
                    placeholder: 'Definition'
              @div class: 'ui green submit button', 'Check'
          @div class: 'column'

    initialize: (@params) ->
      @incorrect = 0
      @collection = @params.collection
      @model = @collection.shift().clone()
      if @model?
        @wordTitle.changeTo @capitalize(@model.get('word'))
      @model.on 'change', (model) =>
        @wordTitle.changeTo @capitalize(model.get('word'))
        @initialize_form()
      @initialize_form()

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

      $form = @find('.ui.form').form(rules, inline: true, on: 'submit')
        .form 'setting',
          onSuccess: =>
            @showNext()
          onFailure: =>
            if @incorrect is 2
              console.log
              @incorrect = 0
              Messenger().post
                message: "The answer is #{definition}"
                type: ''
              @showNext()
            else
              @incorrect++

    showNext: ->
      @incorrect = 0
      if next_word = @collection.shift()
        @model.set(next_word.attributes)
        @find('input').val ''
      else
        Messenger().post
          message: 'There are no more words'
          type: ''
        @go 'home'

  editWords: class EditWords extends Marionette.Layout
    template: Handlebars.compile $('#edit-words-view').html()
    regions:
      main: '#center-column'

    render: ->
      @$el.html @template()
      collectionView = new EditWordsCollection(collection: @collection)
      @main.show collectionView
      searchView = new EditWordsSearch()
        .on 'filterChange', (val) -> collectionView.filterBy(val)
      @router().menu searchView
      this

class AddWordsForm extends View
  @content: ->
    @div class: 'ui form segment', =>
      @subview 'typeDropdown', new TypeDropdown
      @div class: 'field', =>
        @div class: 'ui input', =>
          @input id: 'word-input', type: 'text', name: 'word', placeholder: 'Word'
      @div class: 'field', =>
        @div class: 'ui input', =>
          @input id: 'word-definition', type: 'text', name: 'definition', placeholder: 'Definition'
      @div class: 'ui green submit button', 'Save'

  initialize: ->
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

    $.fn.form.settings.rules.empty = (value) ->
      not (value.length is 0)

    $.fn.form.settings.rules.exists = (value) ->
      not Tutor.get('words').findWhere(word: value)

    $dropdown = @find('.ui.selection.dropdown').dropdown()
    # this is the form so call `this.form`
    @form rules,
      inline: true
      on: 'submit'
    .form 'setting',
      onSuccess: =>
        attr = {}
        attr.type = $dropdown.dropdown('get value')
        if @isString attr.type
          attr.word = @form('get field', 'word').val()
          attr.definition = @form('get field', 'definition').val()
          word = new Word(attr)
            .save {},
              success: (model) =>
                @form('get field', 'word').val ''
                @form('get field', 'definition').val ''
                @find('#word-input').focus()
        else
          Messenger().post
            message: 'Please choose a type'
            type: ''

class TypeDropdown extends View
  @content: ->
    @div class: 'field', =>
      @div class: 'ui selection dropdown', =>
        @input type: 'hidden', name: 'type'
        @div class: 'default text', 'Type'
        @i class: 'dropdown icon'
        @div class: 'menu ui transition hidden', =>
          for type in ['Verb', 'Noun', 'Adjective', 'Stuff']
            @div class: 'item', 'data-value': type.toLowerCase(), type

class WordTitle extends View
  @content: ({word}='') ->
    @div class: 'ui teal medium center aligned header', 'swag'

  changeTo: (word) ->
    @html word

class EditWordView extends Marionette.ItemView
  template: Handlebars.compile $('#edit-word-view').html()
  events:
    'click .red.button': 'delete'

  render: ->
    @$el.html @template(@model.attributes)
    @initialize_form()
    this

  initialize_form: ->
    rules =
      definition:
        identifier: 'definition'
        rules: [
          {
            type: 'empty'
            prompt: 'Need a definition'
          }
        ]

    $form = @$el.find('.ui.form').form(rules, inline: true, on: 'submit')
    $form.form 'setting',
      onSuccess: =>
        new_def = $form.form('get field', 'definition').val()
        @model.save definition: new_def

  delete: (e) -> @model.destroy()

class EditWordsCollection extends Marionette.CollectionView
  itemView: EditWordView

  initialize: -> @filteredBy = ''

  # re-render when filter changes
  filterBy: (val) ->
    @filteredBy = val
    @render()

  # overriding Marionette.CollectionView method to only
  #  show item if it passes filter set by user.
  #  Essentially searching if word contains @filteredBy string
  addItemView: (model) ->
    return unless ~model.get('word').indexOf @filteredBy
    super

class EditWordsSearch extends Marionette.Layout
  template: Handlebars.compile $('#edit-words-search-view').html()
  events:
    'input': (e) -> @trigger 'filterChange', $(e.target).val()
    'click .home.item': (e) -> @router().go 'home'
    'click .study.item': (e) -> @router().go 'studyWords'

class TitleView extends Marionette.ItemView
  template: Handlebars.compile "{{word}}"

class ChooseWordsMenu extends Marionette.ItemView
  template: Handlebars.compile "<i class='home icon'></i>Home"
  tagName: 'a'
  className: 'home item'
  events:
    'click': -> @router().go 'home'
