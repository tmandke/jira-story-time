window.JiraStoryTime.Templates.fetchAll ->
  renderStoryTime = ->
    mainView.applyRadioChange()
    
  $("#ghx-modes").append window.JiraStoryTime.Templates['storyTimeToggle.html']

  $("#story-toggle").on "click", renderStoryTime
  mainView = new window.JiraStoryTime.TopBarView()
