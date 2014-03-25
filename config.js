(function() {
  requirejs.config({
    baseUrl: 'libs',
    paths: {
      main: '../main'
    }
  });

  requirejs(['main'], function(Main) {
    Messenger.options = {
      extraClasses: 'messenger-fixed messenger-on-top',
      theme: 'ice'
    };
    return Main();
  });

}).call(this);
