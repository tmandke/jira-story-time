class JiraStoryTime.Models.Epic extends JiraStoryTime.Utils.Observer
  visible: true
  constructor: (@name, @color, @allStories) ->
    super()
    @observe @allStories
    $.map @allStories, (s) =>
      @observe s
    @recomputePoints()

  onObservedChange: (change) =>
    if change.object is @appStories
      if change.type is 'add'
        @observe @appStories[change.name]
      else if change.type is 'remove'
        @unobserve change.oldValue
      @recomputePoints()
    else if change.name is 'points' or change.name is 'business' or change.epicObj is 'business'
      @recomputePoints()

  recomputePoints: () =>
    points    = 0
    business  = 0
    $.map @allStories, (story) =>
      if story.epicObj is @
        points   += story.points || 0
        business += story.business || 0
      true
    @points   = points
    @business = business


  toggleVisibility: () =>
    @visible = !@visible
    $.map @allStories, (story) =>
      if story.epicObj is @
        story.visible = @visible
      true
