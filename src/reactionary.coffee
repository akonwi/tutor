rdom = React.DOM

tag = (name, args...) ->
  if args[0]?.constructor is Object
    attributes = args.shift()
  else
    attributes = {}

  rdom[name](attributes, args...)

window.DOM = {}
for tagName of rdom
  do (tagName) -> window.DOM[tagName] = tag.bind(@, tagName)
