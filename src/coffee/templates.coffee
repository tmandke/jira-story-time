window.JiraStoryTime = window.JiraStoryTime or {}
window.JiraStoryTime.Templates = class Templates
  @templates = [
    "board"
    "storytoggle"
    "boardRow"
    "boardStory"
    "boardEpic"
    "forcedOrderedBoard"
  ]
    
  @fetchAll: (OnDone) ->
    counter = 0
    @templates.forEach (file_name, i)=>
      $.ajax(
        url: chrome.extension.getURL("/src/templates/" + file_name + ".html")
        context: document.body
      ).done (response) =>
        this[file_name] = response
        counter = counter + 1
        OnDone() if counter is @templates.length
