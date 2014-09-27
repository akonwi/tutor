var rdom, tag, tagName, _fn,
  __slice = [].slice;

rdom = React.DOM;

tag = function() {
  var args, attributes, name, _ref;
  name = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
  if (((_ref = args[0]) != null ? _ref.constructor : void 0) === Object) {
    attributes = args.shift();
  } else {
    attributes = {};
  }
  return rdom[name].apply(rdom, [attributes].concat(__slice.call(args)));
};

window.DOM = {};

_fn = function(tagName) {
  return window.DOM[tagName] = tag.bind(this, tagName);
};
for (tagName in rdom) {
  _fn(tagName);
}
