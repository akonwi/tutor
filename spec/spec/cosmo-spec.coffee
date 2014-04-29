describe "Cosmo", ->
  it 'should have a router class to extend', ->
    expect(Cosmo.Router).not.toBe null
    expect(Cosmo.Router).not.toBe undefined

  class Foobar extends Cosmo.Router
    initialize: -> @set 'initialized', true
    home: -> 'going home'

  class FooView extends View
    @content: ->
      @p 'FooView'

  router = new Foobar

  describe "Cosmo.Router", ->
    it 'will start when told, and call initialize', ->
      router.start()
      expect(router.get('initialized')).toBe true

    it 'can have values set/get on it', ->
      router.set 'name', 'akon'
      expect(router.get('name')).toBe 'akon'

    it 'has regions', ->
      expect(router.get('regions')).toBeDefined()

    it 'will add regions', ->
      router.addRegions another: '#another'
      regions = router.get('regions')
      expect(regions.another).toBeDefined()

    it 'will render into the #container element', ->
      router.render new FooView
      expect(router.get('regions').container.find('p').html()).toBe('FooView')

    it 'will go to routes', ->
      expect(router.go('home')).toBe 'going home'
