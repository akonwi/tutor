Navigation =
  go: (url) -> Tutor.go(url)

StringHandling =
  capitalize: (word) ->
    word[0].toUpperCase() + word[1..-1].toLowerCase()

window.Views = {}

## UrlBtn component
# Simple button that acts as a link
#
# @props url
# @props text to display
UrlBtn = React.createClass
  mixins: [Navigation]
  onClick: (e) -> @go @props.url
  render: ->
    {button} = _
    button onClick: @onClick, @props.text

Views.Home = React.createClass
  render: ->
    {div, h1, h2, li, ul} = _
    div {},
      div className: 'text-center',
        h1 'Tutor'
        h2 "Let's Study!"
      div {},
        ul className: 'unstyled',
          li(UrlBtn url: 'preStudy', text: 'Study')
          li(UrlBtn url: 'addWords', text: 'Add words')
          li(UrlBtn url: 'editWords', text: 'Edit words')

Views.AddWords = React.createClass
  componentDidMount: -> @refs.word.getDOMNode().focus()
  validate: (e) ->
    e.preventDefault()
    valid = true

    wordInput = @refs.word.getDOMNode()
    if wordInput.value.trim() is ''
      wordInput.classList.add('error')
      valid = false
    else
      wordInput.classList.remove('error')

    definitionInput = @refs.definition.getDOMNode()
    if definitionInput.value.trim() is ''
      definitionInput.classList.add('error')
      valid = false
    else
      definitionInput.classList.remove('error')

    if valid
      attrs =
        id: wordInput.value
        definition: definitionInput.value
        type: @refs.types.getDOMNode().value
      word = new Word(attrs)
      word.save {}, success: (saved) ->
        wordInput.value = ''
        wordInput.focus()
        definitionInput.value = ''

  render: ->
    {div, h2, select, option, form, input} = _
    div className: 'text-center',
      h2 'Add Words'
      form id: 'stacked',
        select ref: 'types',
          option value: 'verb', 'Verb'
          option value: 'adjective', 'Adjective'
          option value: 'noun', 'Noun'
          option value: 'stuff', 'Stuff'
        input id: 'word', ref: 'word', type: 'text', placeholder: 'Word'
        input id: 'definition', ref: 'definition', type: 'text', placeholder: 'Definition'
        input className: 'save', type: 'submit', onClick: @validate, value: 'Save'

Views.PreStudy = React.createClass
  render: ->
    {div, h2, h3, ul, li} = _
    div className: 'text-center',
      h2 'Study'
      h3 'Study by type'
      ul className: 'unstyled',
        li(UrlBtn url: 'study/all', text: 'All')
        li(UrlBtn url: 'study/verb', text: 'Verbs')
        li(UrlBtn url: 'study/noun', text: 'Nouns')
        li(UrlBtn url: 'study/adjective', text: 'Adjectives')
        li(UrlBtn url: 'study/stuff', text: 'Stuff')

Views.Study = React.createClass
  mixins: [StringHandling, Navigation]
  getInitialState: -> { word: @props.collection.shift() }
  getInitialProps: -> { wrongCount: 0 }

  validate: (e) ->
    e.preventDefault()
    defInput = @refs.definition.getDOMNode()
    if defInput.value is @state.word.get('definition')
      defInput.classList.remove('error')
      defInput.value = ''
      if @props.collection.hasNext()
        @setState word: @props.collection.shift()
      else
        @go 'index'
        # Messenger.post 'No more words'
    else
      defInput.classList.add('error')

  render: ->
    {div, h2, h3, form, input} = _
    div className: 'text-center',
      h2 'Study'
      h3 @capitalize(@state.word.get('id'))
      form id: 'stacked',
        input id: 'definition', ref: 'definition', type: 'text'
        input className: 'save', type: 'submit', onClick: @validate, value: 'Check'

EditWordForm = React.createClass
  mixins: [StringHandling]

  validate: (e) ->
    e.preventDefault()
    defInput = @refs.definition.getDOMNode()
    if defInput.value.trim() is ''
      defInput.classList.add 'error'
    else
      defInput.classList.remove 'error'
      @props.word.save definition: defInput.value.trim()

  delete: (e) ->
    e.preventDefault()
    #@props.word.destroy()
    console.log @props

  render: ->
    {div, h3, form, input} = _
    word = @props.word
    div null,
      h3 @capitalize(word.get('id'))
      form id: 'stacked',
        input ref: 'definition', type: 'text', defaultValue: word.get('definition')
      input className: 'save', type: 'submit', onClick: @validate, value: 'Update'
      input className: 'save', type: 'submit', onClick: @delete, value: 'Delete'

Views.EditWords = React.createClass
  render: ->
    {div, h2} = _
    words = []
    @props.collection.each (word) ->
      words.push new EditWordForm(word: word)
    div className: 'text-center',
      h2 'Edit'
      words

foobar =
  editWords: class EditWords extends View
    @content: (collection) ->
      @div id: 'content', =>
        @div class: 'ui huge center aligned header', 'Edit'
        @div class: 'ui center aligned three column grid', =>
          @div class: 'column'
          @div class: 'column', =>
            @subview 'wordSection', new WordSection(collection)
          @div class: 'column'

    initialize: -> @menu new EditWordsMenu(@wordSection)

class WordSection extends View
  @content: (collection) ->
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
        if ~view.word.get('id').indexOf query
          view.show()
        else
          view.hide()

class EditWord extends View
  @content: (@word) ->
    @div class: 'ui form segment', =>
      @div class: 'ui huge center header', @word.get('id')
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
            prompt: "Can't be empty"
          }
        ]

    @form rules, inline: true, on: 'submit'
    .form 'setting',
      onSuccess: =>
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
      @a class: 'item', click: 'goAdd', =>
        @raw "<i class='add icon'></i>Add Words"
      @a class: 'item', click: 'goStudy', =>
        @raw "<i class='pencil icon'></i>Study"

  # given the view that is displaying words,
  # trigger updating filter as user types query
  initialize: (wordSection) ->
    searchInput = @find('input')
    .on 'input', =>
      wordSection.trigger 'filterChange', searchInput.val()

  goHome: ->
    @menu()
    @go 'home'

  goAdd: ->
    @menu()
    @go 'addWords'

  goStudy: ->
    @menu()
    @go 'studyWords'

