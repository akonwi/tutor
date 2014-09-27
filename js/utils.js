var idCount;

idCount = 0;

window._ = {
  extend: function(source, ext) {
    var k, v;
    if (!!source.constructor.prototype) {
      for (k in ext) {
        v = ext[k];
        source.constructor.prototype[k] = v;
      }
    } else {
      for (k in ext) {
        v = ext[k];
        source.prototype[k] = v;
      }
    }
    return null;
  },
  clone: function(obj) {
    var key, twin, value;
    twin = null;
    if (this.isArray(obj)) {
      twin = obj.slice();
    } else {
      twin = {};
      for (key in obj) {
        value = obj[key];
        twin[key] = value;
      }
    }
    return twin;
  },
  isArray: function(obj) {
    return toString.call(obj).indexOf('Array') !== -1;
  },
  toArray: function(obj) {
    var array, key, value;
    array = [];
    for (key in obj) {
      value = obj[key];
      array.push(value);
    }
    return array;
  },
  random: function(min, max) {
    if (max == null) {
      max = min;
      min = 0;
    }
    return min + Math.floor(Math.random() * (max - min + 1));
  },
  shuffle: function(array) {
    var index, obj, rand, shuffled, _i, _len;
    shuffled = [];
    for (index = _i = 0, _len = array.length; _i < _len; index = ++_i) {
      obj = array[index];
      rand = this.random(index++);
      shuffled[index - 1] = shuffled[rand];
      shuffled[rand] = obj;
    }
    return shuffled;
  },
  uniqueId: function(prefix) {
    var id;
    id = idCount + '';
    if (prefix) {
      return prefix + id;
    } else {
      return id;
    }
  }
};
