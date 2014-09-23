var DOM, tag, tagName, _fn,
  __slice = [].slice;

DOM = React.DOM;

tag = function() {
  var args, attributes, name, _ref;
  name = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
  if (((_ref = args[0]) != null ? _ref.constructor : void 0) === Object) {
    attributes = args.shift();
  } else {
    attributes = {};
  }
  return DOM[name].apply(DOM, [attributes].concat(__slice.call(args)));
};

window._ = {};

_fn = function(tagName) {
  return window._[tagName] = tag.bind(this, tagName);
};
for (tagName in DOM) {
  _fn(tagName);
}
