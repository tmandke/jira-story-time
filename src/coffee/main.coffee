$ ->
  unless jasmine?
    body = $('body')
    JiraStoryTime.Models.Story.initFieldIds()
    JiraStoryTime.appState = new JiraStoryTime.Models.ApplicationState
    JiraStoryTime.appLauncher = new JiraStoryTime.Views.ApplicationLauncher body, JiraStoryTime.appState
