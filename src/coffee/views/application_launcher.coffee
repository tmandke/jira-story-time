class JiraStoryTime.Views.ApplicationLauncher extends JiraStoryTime.Utils.Observer
  constructor: (@baseElem, @applicationState) ->
    @baseElem.find("#ghx-modes").append(
      JiraStoryTime.Utils.Templates.get('storyTimeToggle.html'))

    @baseElem.find("#story-toggle").on "click", @renderStoryTime

  renderStoryTime: =>
    @applicationState.storyTimeActive = true

