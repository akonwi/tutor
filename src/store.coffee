# Storage adapter for that works with both
#   chrome.storage.local and localStorage
window.Closet = class Closet
  _isChromeApp: false

  # @param name is necessary if using localStorage
  constructor: (name) ->
    if chrome.storage?.local?
      @_isChromeApp = true
      @_storage = chrome.storage.local
      @_runtime = chrome.runtime
    else
      if not name
        throw new Error('Need a name for closet')
      @name = name
      @_storage = localStorage
      unless @_storage.getItem name
        @_storage.setItem name, '{}'

  _toJSON: (obj) -> JSON.stringify(obj)

  _fromJSON: (str) -> JSON.parse(str)

  # read/write to localStorage
  #
  # @optional @param toSave an object to save in localStorage
  _local: (toSave=null) ->
    if toSave?
      @_storage.setItem @name, @_toJSON(toSave)
    else
      @_fromJSON(@_storage.getItem(@name))

  # given a pure json object, it will be saved with it's 'id' as the key
  # callback is given error if it exists
  set: (obj, func) ->
    if @_isChromeApp
      (toSave = {})[obj.id] = obj
      @_storage.set toSave, =>
        if func?
          if err = @_runtime.lastError
            func.call this, err
          else
            func.call this
    else
      id = obj.id
      delete obj.id
      local = @_local()
      local[id] = obj
      @_local(local)
      func.call(this) if func?

  # in Chrome apps, callback is given an array
  # elsewhere, the single object is returned if found
  get: (key, func) ->
    if @_isChromeApp
      @_storage.get key, (results) ->
        func.call this, _.toArray(results)
    else
      results = @_local()[key]
      if func? then func.call(this, results) else results

  all: (func) ->
    if @_isChromeApp
      @_storage.get null, (items) ->
        func.call this, _.toArray(items)
    else
      all = _.toArray(@_local)
      if func then func.call(this, all) else all

  remove: (key, func) ->
    if @_isChromeApp
      @_storage.remove key, ->
        if func?
          if err = @runtime.lastError
            func.call this, err
          else
            func.call this
    else
      l = @_local()
      delete l[key]
      @_local(l)

# simple wrapper class for chrome.storage.local
window.Store = class Store
  # given a pure json object, it will be saved with it's 'id' as the key
  # callback is given error if it exists
  set: (obj, func) ->
    (toSave = {})[obj.id] = obj
    console.log "to save", toSave
    storage.set toSave, =>
      if func?
        if error = runtime.lastError
          func.call this, error
        else
          func.call(this)

  # follows chrome api but results given to callback will be an array
  get: (key, func) ->
    storage.get key, (results) ->
      func.call this, _.toArray(results)

  # like ::get but returns only the first result
  getOne: (key, func) ->
    @get key, (results) ->
      func.call this, results[0]

  # chrome api will return an object so convert it to array
  all: (func) ->
    storage.get null, (items) ->
      func.call this, _.toArray(items)

  # follows chrome api but callback is given error
  remove: (key, func) ->
    storage.remove key, ->
      if func?
        if error = runtime.lastError
          func.call this, error
        else
          func.call this
