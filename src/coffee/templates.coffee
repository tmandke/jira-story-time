window.JiraStoryTime = window.JiraStoryTime or {}
window.JiraStoryTime.Templates = fetchAll: (OnDone) ->
  _this = this
  counter = 0
  tmpls = [
    "board"
    "storytoggle"
    "boardRow"
    "boardStory"
    "boardEpic"
  ]
  $.map tmpls, (file_name) ->
    $.ajax(
      url: chrome.extension.getURL("/src/templates/" + file_name + ".html")
      context: document.body
    ).done (response) ->
      _this[file_name] = response
      counter = counter + 1
      OnDone()  if counter is tmpls.length
      return

    return

  return