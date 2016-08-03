$ ->
  unless jasmine?
    body = $('body')
    JiraStoryTime.Models.Story.initFieldIds().done ->
      JiraStoryTime.appState = new JiraStoryTime.Models.ApplicationState
      JiraStoryTime.appLauncher = new JiraStoryTime.Views.ApplicationLauncher body, JiraStoryTime.appState
