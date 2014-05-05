chrome.app.runtime.onLaunched.addListener ->
  chrome.app.window.create 'index.html',
    bounds:
      width: 600
      height: 600
