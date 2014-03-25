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
        'click #edit-words-button': (e) -> @router().go 'edit'

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
                  $form.form('get field', 'word').val ''
                  $form.form('get field', 'definition').val ''
                  $('#word-input').focus()
            else
              Messenger().post
                message: 'Please choose a type'
                type: ''

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
            unless word_type is 'all'
              words = new Words(words).where(type: word_type)
            @router().go 'studyWords', words
          onFailure: ->
            Messenger().post
              message: 'Please choose which type of words to study'
              type: ''

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

      onRender: ->
        alert 'renderd'

      showNext: ->
        if next_word = @collection.shift()
          @model.set(next_word.attributes)
          $('#definition-input').val ''
        else
          Messenger().post
            message: 'There are no more words'
            type: ''
          @router().go 'home'

    editWords: class EditWords extends Marionette.Layout
      template: Handlebars.compile $('#edit-words-view').html()
      regions:
        main: '#center-column'
        search: '#search-column'

      render: ->
        @$el.html @template()
        collectionView = new EditWordsCollection(collection: @collection)
        @main.show collectionView
        searchView = new EditWordsSearch()
          .on 'filterChange', (val) -> collectionView.filterBy(val)
        @search.show searchView
        this

  class EditWordView extends Marionette.ItemView
    template: Handlebars.compile $('#edit-word-view').html()

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

  class EditWordsCollection extends Marionette.CollectionView
    itemView: EditWordView

    initialize: ->
      @filteredBy = ''
      # keep track of how many results are shown
      @count = 0

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

    onAfterItemAdded: (view) ->
      @count++

    onItemRemoved: (view) ->
      @count--
      if @count is 0
        Messenger().error
          message: 'No words found'
          hideAfter: 3

  # Sidebar Menu with search bar in edit view
  # TODO: make this a region in Tutor namespace and modify
  #  per route
  class EditWordsSearch extends Marionette.Layout
    template: Handlebars.compile $('#edit-words-search-view').html()
    className: 'ui inverted floating thin right sidebar vertical menu active'
    events:
      'input': (e) -> @trigger 'filterChange', $(e.target).val()

  class TitleView extends Marionette.ItemView
    template: Handlebars.compile "{{word}}"

  to_return
