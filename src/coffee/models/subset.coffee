class JiraStoryTime.Models.Subset extends JiraStoryTime.Utils.Observer
  visible: true
  constructor: (@subsetVar, @name, @color, @allStories) ->
    super()
    @observe @allStories
    $.map @allStories, (s) =>
      @observe s
    @recomputePoints()

  deconstruct: =>
    @unobserveAll()

  onObservedChange: (change) =>
    if change.object is @allStories
      if change.type is 'add'
        @observe @allStories[change.name]
      else if change.type is 'delete'
        @unobserve change.oldValue
      @recomputePoints()
    else if change.name is 'points' or change.name is 'business' or change.name is "subset_#{@subsetVar}"
      if change.object["subset_#{@subsetVar}"] is this
        change.object.visible = @visible
        change.object.color = @color
      @recomputePoints()

  recomputePoints: () =>
    points    = 0
    business  = 0
    $.map @allStories, (story) =>
      if story["subset_#{@subsetVar}"] is this
        points   += story.points || 0
        business += story.business || 0
      true
    @points   = points
    @business = business


  toggleVisibility: () =>
    @visible = !@visible
    $.map @allStories, (story) =>
      if story["subset_#{@subsetVar}"] is this
        story.visible = @visible
      true
