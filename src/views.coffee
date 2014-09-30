Navigation =
  go: (url) -> Tutor.go(url)

StringHandling =
  capitalize: (word) ->
    word[0].toUpperCase() + word[1..-1].toLowerCase()

cx = React.addons.classSet

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
    {button} = DOM
    button onClick: @onClick, @props.text

Views.Home = React.createClass
  render: ->
    {div, h1, h2, li, ul} = DOM
    div {},
      div className: 'text-center',
        h1 'Tutor'
        h2 "Let's Study!"
      div {},
        ul className: 'unstyled vertical text-center',
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
    {div, h2, select, option, form, input} = DOM
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
        input className: 'save green', type: 'submit', onClick: @validate, value: 'Save'

Views.PreStudy = React.createClass
  render: ->
    {div, h2, h3, ul, li} = DOM
    div className: 'text-center',
      h2 'Study'
      h3 'Study by type'
      ul className: 'unstyled vertical',
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
        Tutor.trigger 'message', 'No more words'
        @go 'index'
    else
      defInput.classList.add('error')

  render: ->
    {div, h2, h3, form, input} = DOM
    div className: 'text-center',
      h2 'Study'
      h3 @capitalize(@state.word.get('id'))
      form id: 'stacked',
        input id: 'definition', ref: 'definition', type: 'text'
        input className: 'save green', type: 'submit', onClick: @validate, value: 'Check'

EditWordForm = React.createClass
  mixins: [StringHandling]

  getInitialState: -> { hidden: false }

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
    @props.word.destroy()
    @setState hidden: true

  render: ->
    {div, h3, form, input} = DOM
    word = @props.word
    classes = cx('hidden': @state.hidden)
    div className: classes,
      h3 @capitalize(word.get('id'))
      form id: 'stacked',
        input ref: 'definition', type: 'text', defaultValue: word.get('definition')
      input className: 'save green', type: 'submit', onClick: @validate, value: 'Update'
      input className: 'save red', type: 'submit', onClick: @delete, value: 'Delete'

Views.EditWords = React.createClass
  render: ->
    {div, h2} = DOM
    forms = []
    @props.collection.each (word) ->
      forms.push new EditWordForm(word: word)
    div className: 'text-center',
      h2 'Edit'
      forms

# Menu with navigation buttons
# Listens for 'change:menu' event triggered by app
# Trigger should also pass an array of objects with
#   'route' and 'text' keys
#
# @props app application instance to subscribe to
Views.NavBar = React.createClass
  getInitialState: -> {urls: []}
  render: ->
    @props.app.on 'change:menu', (urls) =>
      @setState(urls: urls)
    {ul, li} = DOM
    buttons = {}
    for {route, text} in @state.urls
      buttons[route] = li(null, new UrlBtn(url: route, text: text))
    ul className: 'unstyled', buttons

# Basic notification component
# Listens for 'message' event triggered by app
# Trigger should also pass a string to be displayed
# Disappears after 5 seconds
#
# @props app application instance to subscribe to
Views.Message = React.createClass
  getInitialState: -> { message: '' }
  render: ->
    @props.app.on 'message', (text) =>
      @setState message: text
    {div} = DOM
    classes = if @state.message.trim().length is 0 then 'hidden' else ''
    if classes is ''
      clearMe = => @setState message: ''
      setTimeout(clearMe, 5000)
    div id: 'message', className: classes, @state.message
