window.Tutor = Ember.Application.create()
Tutor.ApplicationSerializer = DS.LSSerializer.extend()
Tutor.ApplicationAdapter = DS.LSAdapter.extend
  namespace: 'tutor-ember'

Tutor.Router.map ->
  @route 'home', path: '/'
  @route 'addWords'
  @resource 'study', ->
    @route 'index', path: '/'
    @route 'words', path: '/:type'

Tutor.HomeRoute = Ember.Route.extend
  model: -> @store.find 'word'

Tutor.AddWordsForm = Ember.View.extend
  templateName: 'addWordsForm'
  store: (->
    @get('controller').get('store')
  ).property()

  submit: ->
    type = @get('dropdown').dropdown('get value')
    if typeof type is 'string'
      word = @get('word')
      def = @get('definition')
      # TODO: bind the blanks to input classes
      if Ember.isEmpty(word) or Ember.isEmpty(def)
        Messenger().post type: 'error', message: "Can't have blanks"
      else
        record = @get('store').createRecord 'word',
          type: type
          word: word
          definition: def
        record.save()
        @set 'word', ''
        @set 'definition', ''

 didInsertElement: ->
   dropdown = $('.ui.selection.dropdown').dropdown()
   @set 'dropdown', dropdown
   $('.ui.form').form()

Tutor.ChooseTypeForm = Ember.View.extend
  didInsertElement: ->
    dropdown = $('.ui.selection.dropdown').dropdown()
    @set 'dropdown', dropdown

  continue: ->
    type = @get('dropdown').dropdown('get value')
    # The 'all' option won't have a value to retrieve
    # so if it is not a string, it's the 'all' option
    unless typeof type is 'string'
      type = 'all'
    @get('controller').transitionToRoute 'study.words', type

Tutor.ChooseContinueBtn = Ember.View.extend
  click: ->
    @get('parentView').continue()

Tutor.StudyWordsController = Ember.ArrayController.extend
  currentWord: (->
    @get('model').get('firstObject')
  ).property 'model'

  isWrong: false

  actions:
    check: ->
      form = $('.ui.form').form()
      def = @get('definition')
      answer = @get('currentWord.definition')
      if def is answer
        @set 'definition', ''
        @set 'isWrong', false
        @showNext()
      else
        @set 'isWrong', true

  showNext: ->
    # 'pop' currentWord from the RecordArray
    newModel = @get('model').without @get('currentWord')
    @set 'model', newModel
    if newModel.get('length') is 0
      Messenger().post type: '', message: 'No more words'
      @transitionToRoute 'home'
    else
      @set 'currentWord', newModel.get('firstObject')

Tutor.StudyWordsRoute = Ember.Route.extend
  model: (params) ->
    type = params.type
    if type is 'all'
      @store.find('word')
    else
      @store.find 'word', type: type

Tutor.Word = DS.Model.extend
  type: DS.attr 'string'
  word: DS.attr 'string'
  definition: DS.attr 'string'

Messenger.options =
  extraClasses: 'messenger-fixed messenger-on-top'
  theme: 'ice'
