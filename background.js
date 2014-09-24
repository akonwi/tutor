chrome.app.runtime.onLaunched.addListener(function() {
  return chrome.app.window.create('index.html', {
    bounds: {
      width: 400,
      height: 400
    }
  });
});
