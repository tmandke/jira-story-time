mainView = null
renderStoryTime = ->
  mainView ||= new window.JiraStoryTime.TopBarView()
  mainView.applyRadioChange()

$("#ghx-modes").append window.JiraStoryTime.Utils.Templates.get('storyTimeToggle.html')

$("#story-toggle").on "click", renderStoryTime
