var EditWordForm, Navigation, StringHandling, UrlBtn, cx;

Navigation = {
  go: function(url) {
    return Tutor.go(url);
  }
};

StringHandling = {
  capitalize: function(word) {
    return word[0].toUpperCase() + word.slice(1).toLowerCase();
  }
};

cx = React.addons.classSet;

window.Views = {};

UrlBtn = React.createClass({
  mixins: [Navigation],
  onClick: function(e) {
    return this.go(this.props.url);
  },
  render: function() {
    var button;
    button = _.button;
    return button({
      onClick: this.onClick
    }, this.props.text);
  }
});

Views.Home = React.createClass({
  render: function() {
    var div, h1, h2, li, ul;
    div = _.div, h1 = _.h1, h2 = _.h2, li = _.li, ul = _.ul;
    return div({}, div({
      className: 'text-center'
    }, h1('Tutor'), h2("Let's Study!")), div({}, ul({
      className: 'unstyled'
    }, li(UrlBtn({
      url: 'preStudy',
      text: 'Study'
    })), li(UrlBtn({
      url: 'addWords',
      text: 'Add words'
    })), li(UrlBtn({
      url: 'editWords',
      text: 'Edit words'
    })))));
  }
});

Views.AddWords = React.createClass({
  componentDidMount: function() {
    return this.refs.word.getDOMNode().focus();
  },
  validate: function(e) {
    var attrs, definitionInput, valid, word, wordInput;
    e.preventDefault();
    valid = true;
    wordInput = this.refs.word.getDOMNode();
    if (wordInput.value.trim() === '') {
      wordInput.classList.add('error');
      valid = false;
    } else {
      wordInput.classList.remove('error');
    }
    definitionInput = this.refs.definition.getDOMNode();
    if (definitionInput.value.trim() === '') {
      definitionInput.classList.add('error');
      valid = false;
    } else {
      definitionInput.classList.remove('error');
    }
    if (valid) {
      attrs = {
        id: wordInput.value,
        definition: definitionInput.value,
        type: this.refs.types.getDOMNode().value
      };
      word = new Word(attrs);
      return word.save({}, {
        success: function(saved) {
          wordInput.value = '';
          wordInput.focus();
          return definitionInput.value = '';
        }
      });
    }
  },
  render: function() {
    var div, form, h2, input, option, select;
    div = _.div, h2 = _.h2, select = _.select, option = _.option, form = _.form, input = _.input;
    return div({
      className: 'text-center'
    }, h2('Add Words'), form({
      id: 'stacked'
    }, select({
      ref: 'types'
    }, option({
      value: 'verb'
    }, 'Verb'), option({
      value: 'adjective'
    }, 'Adjective'), option({
      value: 'noun'
    }, 'Noun'), option({
      value: 'stuff'
    }, 'Stuff')), input({
      id: 'word',
      ref: 'word',
      type: 'text',
      placeholder: 'Word'
    }), input({
      id: 'definition',
      ref: 'definition',
      type: 'text',
      placeholder: 'Definition'
    }), input({
      className: 'save green',
      type: 'submit',
      onClick: this.validate,
      value: 'Save'
    })));
  }
});

Views.PreStudy = React.createClass({
  render: function() {
    var div, h2, h3, li, ul;
    div = _.div, h2 = _.h2, h3 = _.h3, ul = _.ul, li = _.li;
    return div({
      className: 'text-center'
    }, h2('Study'), h3('Study by type'), ul({
      className: 'unstyled'
    }, li(UrlBtn({
      url: 'study/all',
      text: 'All'
    })), li(UrlBtn({
      url: 'study/verb',
      text: 'Verbs'
    })), li(UrlBtn({
      url: 'study/noun',
      text: 'Nouns'
    })), li(UrlBtn({
      url: 'study/adjective',
      text: 'Adjectives'
    })), li(UrlBtn({
      url: 'study/stuff',
      text: 'Stuff'
    }))));
  }
});

Views.Study = React.createClass({
  mixins: [StringHandling, Navigation],
  getInitialState: function() {
    return {
      word: this.props.collection.shift()
    };
  },
  getInitialProps: function() {
    return {
      wrongCount: 0
    };
  },
  validate: function(e) {
    var defInput;
    e.preventDefault();
    defInput = this.refs.definition.getDOMNode();
    if (defInput.value === this.state.word.get('definition')) {
      defInput.classList.remove('error');
      defInput.value = '';
      if (this.props.collection.hasNext()) {
        return this.setState({
          word: this.props.collection.shift()
        });
      } else {
        return this.go('index');
      }
    } else {
      return defInput.classList.add('error');
    }
  },
  render: function() {
    var div, form, h2, h3, input;
    div = _.div, h2 = _.h2, h3 = _.h3, form = _.form, input = _.input;
    return div({
      className: 'text-center'
    }, h2('Study'), h3(this.capitalize(this.state.word.get('id'))), form({
      id: 'stacked'
    }, input({
      id: 'definition',
      ref: 'definition',
      type: 'text'
    }), input({
      className: 'save green',
      type: 'submit',
      onClick: this.validate,
      value: 'Check'
    })));
  }
});

EditWordForm = React.createClass({
  mixins: [StringHandling],
  getInitialState: function() {
    return {
      hidden: false
    };
  },
  validate: function(e) {
    var defInput;
    e.preventDefault();
    defInput = this.refs.definition.getDOMNode();
    if (defInput.value.trim() === '') {
      return defInput.classList.add('error');
    } else {
      defInput.classList.remove('error');
      return this.props.word.save({
        definition: defInput.value.trim()
      });
    }
  },
  "delete": function(e) {
    e.preventDefault();
    this.props.word.destroy();
    return this.setState({
      hidden: true
    });
  },
  render: function() {
    var classes, div, form, h3, input, word;
    div = _.div, h3 = _.h3, form = _.form, input = _.input;
    word = this.props.word;
    classes = cx({
      'hidden': this.state.hidden
    });
    return div({
      className: classes
    }, h3(this.capitalize(word.get('id'))), form({
      id: 'stacked'
    }, input({
      ref: 'definition',
      type: 'text',
      defaultValue: word.get('definition')
    })), input({
      className: 'save green',
      type: 'submit',
      onClick: this.validate,
      value: 'Update'
    }), input({
      className: 'save red',
      type: 'submit',
      onClick: this["delete"],
      value: 'Delete'
    }));
  }
});

Views.EditWords = React.createClass({
  render: function() {
    var div, forms, h2;
    div = _.div, h2 = _.h2;
    forms = [];
    this.props.collection.each(function(word) {
      return forms.push(new EditWordForm({
        word: word
      }));
    });
    return div({
      className: 'text-center'
    }, h2('Edit'), forms);
  }
});

Views.NavBar = React.createClass({
  getInitialState: function() {
    return {
      urls: [],
      count: 0
    };
  },
  render: function() {
    var buttons, li, route, text, ul, _i, _len, _ref, _ref1;
    this.props.app.on('change:menu', (function(_this) {
      return function(urls) {
        var count;
        count = _this.state.count + 1;
        console.log("called " + count);
        return _this.setState({
          urls: urls,
          count: count
        });
      };
    })(this));
    ul = _.ul, li = _.li;
    buttons = {};
    _ref = this.state.urls;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      _ref1 = _ref[_i], route = _ref1.route, text = _ref1.text;
      buttons[route] = new UrlBtn({
        url: route,
        text: text
      });
    }
    return ul(null, buttons);
  }
});
