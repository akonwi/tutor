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
    button = DOM.button;
    return button({
      onClick: this.onClick
    }, this.props.text);
  }
});

Views.Home = React.createClass({
  render: function() {
    var div, h1, h2, li, ul;
    div = DOM.div, h1 = DOM.h1, h2 = DOM.h2, li = DOM.li, ul = DOM.ul;
    return div({}, div({
      className: 'text-center'
    }, h1('Tutor'), h2("Let's Study!")), div({}, ul({
      className: 'unstyled vertical text-center'
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
    div = DOM.div, h2 = DOM.h2, select = DOM.select, option = DOM.option, form = DOM.form, input = DOM.input;
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
    div = DOM.div, h2 = DOM.h2, h3 = DOM.h3, ul = DOM.ul, li = DOM.li;
    return div({
      className: 'text-center'
    }, h2('Study'), h3('Study by type'), ul({
      className: 'unstyled vertical'
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
        Tutor.trigger('message', 'No more words');
        return this.go('index');
      }
    } else {
      return defInput.classList.add('error');
    }
  },
  render: function() {
    var div, form, h2, h3, input;
    div = DOM.div, h2 = DOM.h2, h3 = DOM.h3, form = DOM.form, input = DOM.input;
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
    div = DOM.div, h3 = DOM.h3, form = DOM.form, input = DOM.input;
    word = this.props.word;
    classes = cx({
      'hidden': this.state.hidden,
      'edit-word': true
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
    div = DOM.div, h2 = DOM.h2;
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
      urls: []
    };
  },
  render: function() {
    var buttons, li, route, text, ul, _i, _len, _ref, _ref1;
    this.props.app.on('change:menu', (function(_this) {
      return function(urls) {
        return _this.setState({
          urls: urls
        });
      };
    })(this));
    ul = DOM.ul, li = DOM.li;
    buttons = {};
    _ref = this.state.urls;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      _ref1 = _ref[_i], route = _ref1.route, text = _ref1.text;
      buttons[route] = li(null, new UrlBtn({
        url: route,
        text: text
      }));
    }
    return ul({
      className: 'unstyled'
    }, buttons);
  }
});

Views.Message = React.createClass({
  getInitialState: function() {
    return {
      message: ''
    };
  },
  render: function() {
    var classes, clearMe, div;
    this.props.app.on('message', (function(_this) {
      return function(text) {
        return _this.setState({
          message: text
        });
      };
    })(this));
    div = DOM.div;
    classes = this.state.message.trim().length === 0 ? 'hidden' : '';
    if (classes === '') {
      clearMe = (function(_this) {
        return function() {
          return _this.setState({
            message: ''
          });
        };
      })(this);
      setTimeout(clearMe, 5000);
    }
    return div({
      id: 'message',
      className: classes
    }, this.state.message);
  }
});
