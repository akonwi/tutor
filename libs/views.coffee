View::go = (page, args...) ->
  switch args.length
    when 1 then Tutor.go page, args[0]
    when 2 then Tutor.go page, args[0], args[1]
    else Tutor.go page

View::isString = (obj) ->
  toString.call(obj).indexOf('String') isnt -1

View::capitalize = (word) ->
  word[0].toUpperCase() + word[1..-1].toLowerCase()

View::menu = (view) -> Tutor.get('regions').sidebar.html view

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
      $form.form rules, on: 'submit'
      .form 'setting',
        onSuccess: =>
          word_type = $dropdown.dropdown('get value')
          Tutor.get('lawnchair').all (words) =>
            collection = new Words(words)
            unless word_type is 'all'
              collection = new Words(collection.where(type: word_type))
            if collection.length is 0
              Messenger().post
                message: 'There are no words'
                type: ''
              @go 'home'
            else
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
      @model = @collection.shift()?.clone()
      @initialize_form()
      @wordTitle.changeTo @capitalize(@model.get('word'))
      @model.on 'change', (model) =>
        @wordTitle.changeTo @capitalize(model.get('word'))
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

  editWords: class EditWords extends View
    @content: (params) ->
      @div id: 'content', =>
        @div class: 'ui huge center aligned header', 'Edit'
        @div class: 'ui center aligned three column grid', =>
          @div class: 'column'
          @div class: 'column', =>
            @subview 'wordSection', new WordSection(params)
          @div class: 'column'

    initialize: -> @menu new EditWordsMenu(@wordSection)

class WordSection extends View
  @content: ({collection}) ->
    # collection of subviews for each word to edit
    @subViews = []
    @div id: 'content', =>
      collection.each (word) =>
        view = new EditWord(word)
        @subViews.push view
        @subview 'word', view

  initialize: ->
    # filter which words are shown based on user input
    @on 'filterChange', (e, query) =>
      for view in @constructor.subViews
        if ~view.word.get('word').indexOf query
          view.show()
        else
          view.hide()

class EditWord extends View
  @content: (@word) ->
    @div class: 'ui form segment', =>
      @div class: 'ui huge center header', @word.get('word')
      @div class: 'field', =>
        @div class: 'ui input', =>
          @input id: 'definition-input',
            type: 'text',
            name: 'definition',
            value: @word.get('definition'),
            placeholder: 'Definition'
      @div class: 'ui green submit mini button', 'Update'
      @div class: 'ui red mini button', click: 'delete', 'Delete'

  initialize: (@word) ->
    rules =
      definition:
        identifier: 'definition'
        rules: [
          {
            type: 'empty'
            prompt: 'Need a definition'
          }
        ]

    @form rules, inline: true, on: 'submit'
    .form 'setting',
      onSuccess: =>
        new_def = @form('get field', 'definition').val()
        @word.save definition: new_def

  delete: ->
    @word.destroy()
    @hide()

class EditWordsMenu extends View
  @content: ->
    @div id: 'content', =>
      @div class: 'item', =>
        @div class: 'ui form', =>
          @div class: 'field', =>
            @div class: 'ui small icon input', =>
              @input id: 'search-input',
                type: 'text',
                name: 'search',
                placeholder: 'Search'
              @i class: 'search icon'
      @a class: 'item', click: 'goHome', =>
        @raw "<i class='home icon'></i>Home"
      @a class: 'item', click: 'goStudy', =>
        @raw "<i class='pencil icon'></i>Study"

  # given the view that is displaying words,
  # trigger updating filter as user types query
  initialize: (wordSection) ->
    searchInput = @find('input')
    .on 'input', =>
      wordSection.trigger 'filterChange', searchInput.val()

  goHome: ->
    @menu ''
    @go 'home'

  goStudy: ->
    @menu ''
    @go 'studyWords'

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
  @content: (word='') ->
    @div class: 'ui teal medium center aligned header', word

  changeTo: (word) ->
    @html word
