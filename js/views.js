var EditWord, EditWordForm, EditWords, EditWordsMenu, Navigation, StringHandling, UrlBtn, WordSection, cx, foobar,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

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
      className: 'save',
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
      className: 'save',
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
      className: 'save',
      type: 'submit',
      onClick: this.validate,
      value: 'Update'
    }), input({
      className: 'save',
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
      console.log(word.get('id'));
      return forms.push(new EditWordForm({
        word: word
      }));
    });
    return div({
      className: 'text-center'
    }, h2('Edit'), forms);
  }
});

foobar = {
  editWords: EditWords = (function(_super) {
    __extends(EditWords, _super);

    function EditWords() {
      return EditWords.__super__.constructor.apply(this, arguments);
    }

    EditWords.content = function(collection) {
      return this.div({
        id: 'content'
      }, (function(_this) {
        return function() {
          _this.div({
            "class": 'ui huge center aligned header'
          }, 'Edit');
          return _this.div({
            "class": 'ui center aligned three column grid'
          }, function() {
            _this.div({
              "class": 'column'
            });
            _this.div({
              "class": 'column'
            }, function() {
              return _this.subview('wordSection', new WordSection(collection));
            });
            return _this.div({
              "class": 'column'
            });
          });
        };
      })(this));
    };

    EditWords.prototype.initialize = function() {
      return this.menu(new EditWordsMenu(this.wordSection));
    };

    return EditWords;

  })(View)
};

WordSection = (function(_super) {
  __extends(WordSection, _super);

  function WordSection() {
    return WordSection.__super__.constructor.apply(this, arguments);
  }

  WordSection.content = function(collection) {
    this.subViews = [];
    return this.div({
      id: 'content'
    }, (function(_this) {
      return function() {
        return collection.each(function(word) {
          var view;
          view = new EditWord(word);
          _this.subViews.push(view);
          return _this.subview('word', view);
        });
      };
    })(this));
  };

  WordSection.prototype.initialize = function() {
    return this.on('filterChange', (function(_this) {
      return function(e, query) {
        var view, _i, _len, _ref, _results;
        _ref = _this.constructor.subViews;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          view = _ref[_i];
          if (~view.word.get('id').indexOf(query)) {
            _results.push(view.show());
          } else {
            _results.push(view.hide());
          }
        }
        return _results;
      };
    })(this));
  };

  return WordSection;

})(View);

EditWord = (function(_super) {
  __extends(EditWord, _super);

  function EditWord() {
    return EditWord.__super__.constructor.apply(this, arguments);
  }

  EditWord.content = function(word) {
    this.word = word;
    return this.div({
      "class": 'ui form segment'
    }, (function(_this) {
      return function() {
        _this.div({
          "class": 'ui huge center header'
        }, _this.word.get('id'));
        _this.div({
          "class": 'field'
        }, function() {
          return _this.div({
            "class": 'ui input'
          }, function() {
            return _this.input({
              id: 'definition-input'
            }, {
              type: 'text',
              name: 'definition',
              value: _this.word.get('definition'),
              placeholder: 'Definition'
            });
          });
        });
        _this.div({
          "class": 'ui green submit mini button'
        }, 'Update');
        return _this.div({
          "class": 'ui red mini button',
          click: 'delete'
        }, 'Delete');
      };
    })(this));
  };

  EditWord.prototype.initialize = function(word) {
    var rules;
    this.word = word;
    rules = {
      definition: {
        identifier: 'definition',
        rules: [
          {
            type: 'empty',
            prompt: "Can't be empty"
          }
        ]
      }
    };
    return this.form(rules, {
      inline: true,
      on: 'submit'
    }).form('setting', {
      onSuccess: (function(_this) {
        return function() {
          return _this.word.save({
            definition: new_def
          });
        };
      })(this)
    });
  };

  EditWord.prototype["delete"] = function() {
    this.word.destroy();
    return this.hide();
  };

  return EditWord;

})(View);

EditWordsMenu = (function(_super) {
  __extends(EditWordsMenu, _super);

  function EditWordsMenu() {
    return EditWordsMenu.__super__.constructor.apply(this, arguments);
  }

  EditWordsMenu.content = function() {
    return this.div({
      id: 'content'
    }, (function(_this) {
      return function() {
        _this.div({
          "class": 'item'
        }, function() {
          return _this.div({
            "class": 'ui form'
          }, function() {
            return _this.div({
              "class": 'field'
            }, function() {
              return _this.div({
                "class": 'ui small icon input'
              }, function() {
                _this.input({
                  id: 'search-input'
                }, {
                  type: 'text',
                  name: 'search',
                  placeholder: 'Search'
                });
                return _this.i({
                  "class": 'search icon'
                });
              });
            });
          });
        });
        _this.a({
          "class": 'item',
          click: 'goHome'
        }, function() {
          return _this.raw("<i class='home icon'></i>Home");
        });
        _this.a({
          "class": 'item',
          click: 'goAdd'
        }, function() {
          return _this.raw("<i class='add icon'></i>Add Words");
        });
        return _this.a({
          "class": 'item',
          click: 'goStudy'
        }, function() {
          return _this.raw("<i class='pencil icon'></i>Study");
        });
      };
    })(this));
  };

  EditWordsMenu.prototype.initialize = function(wordSection) {
    var searchInput;
    return searchInput = this.find('input').on('input', (function(_this) {
      return function() {
        return wordSection.trigger('filterChange', searchInput.val());
      };
    })(this));
  };

  EditWordsMenu.prototype.goHome = function() {
    this.menu();
    return this.go('home');
  };

  EditWordsMenu.prototype.goAdd = function() {
    this.menu();
    return this.go('addWords');
  };

  EditWordsMenu.prototype.goStudy = function() {
    this.menu();
    return this.go('studyWords');
  };

  return EditWordsMenu;

})(View);
