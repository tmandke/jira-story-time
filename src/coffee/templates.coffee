window.JiraStoryTime = window.JiraStoryTime or {}
window.JiraStoryTime.Templates = class Templates
  @templates = [
    "board.html"
    "storyTimeToggle.html"
    "regularColumn.html"
    "storyCard.html"
    "epic.html"
    "forcedOrderingView.html"
    "pointCard.html"
    "styles.css"
  ]
    
  @fetchAll: (OnDone) ->
    counter = 0
    @templates.forEach (file_name, i)=>
      $.ajax(
        url: chrome.extension.getURL("/templates/" + file_name)
        context: document.body
      ).done (response) =>
        this[file_name] = response
        counter = counter + 1
        OnDone() if counter is @templates.length
