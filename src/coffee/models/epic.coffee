class JiraStoryTime.Models.Epic
  visible: true
  constructor: (@name, @color, @allStories) ->

  toggleVisibility: () =>
    @visible = !@visible
    $.map @allStories, (story) =>
      if story.epicObj is @
        story.visible = @visible
      true
