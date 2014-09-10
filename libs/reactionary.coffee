{DOM} = React

tag = (name, args...) ->
  if args[0]?.constructor is Object
    attributes = args.shift()
  else
    attributes = {}

  DOM[name](attributes, args...)

window._ = {}
for tagName of DOM
  do (tagName) -> window._[tagName] = tag.bind(@, tagName)
