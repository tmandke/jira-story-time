class JiraStoryTime.Views.RegularStoryTime extends JiraStoryTime.Utils.Observer
  storyViewToDropZoneList: {}
  storyViews: {}
  dropZones: {}
  dropZoneLists: {}
  possibleValues: [undefined, 1, 2]
  constructor: (@applicationState, @backlog) ->
    super()
    @observe @applicationState
    @observe @backlog.stories
    @el = $('<div id="story_board"></div>')
    @setValueProperty()
    $.map @backlog.stories, @createStroyView
    @createDropZones()
    @reorgenizeStories()

  onObservedChange: (change) =>
    if change.object is @applicationState
      if change.name is 'pointsType'
        @setValueProperty()
        @reorgenizeStories()
    else if change.object is @backlog.stories
      if change.type is 'add'
        @placeStoryView @createStroyView(change.object[change.name])
      else if change.type is 'delete'
        @removeStoryView @storyViews[change.name]
        @storyViews[change.name].deconstruct()
    else if @storyViews[change.object.id]? and (change.name is @valueProperty or change.name is 'sprintState' or change.name is 'subset_epic')
      @placeStoryView(@storyViews[change.object.id])

  currentFib: () => @possibleValues[@possibleValues.length - 1]

  prevFib: () => @possibleValues[@possibleValues.length - 2]

  setValueProperty: () =>
    @valueProperty = if @applicationState.pointsType is 'Story Points' then 'points' else 'business'

  reorgenizeStories: () =>
    $.map @storyViews, @removeStoryView
    $.map @storyViews, @placeStoryView

  createDropZones: () =>
    @possibleValues.forEach @createDropZone

  createDropZone: (v) =>
    @dropZoneLists[v] = [{backlogBanner: true, story: {}, el: $('<div class="backlog story-item">Backlog</div>')}]
    @dropZones[v] = new JiraStoryTime.Views.DropZone(@dropZoneLists[v], v, @dropHandler)
    @el.append(@dropZones[v].el)

  createNextDropZone: () =>
    nextFib = @prevFib() + @currentFib()
    @possibleValues.push(nextFib)
    @createDropZone(nextFib)

  createStroyView: (story) =>
    @observe(story)
    @storyViews[story.id] = new JiraStoryTime.Views.Story(story)

  removeStoryView: (storyView) =>
    if @storyViewToDropZoneList[storyView.story.id]?
      @storyViewToDropZoneList[storyView.story.id].splice(
        @storyViewToDropZoneList[storyView.story.id].indexOf(storyView),
        1
      )
      delete @storyViewToDropZoneList[storyView.story.id]

  placeStoryView: (storyView) =>
    @removeStoryView(storyView)
    @ensureDropZone(storyView.story[@valueProperty])
    storyViews = @dropZoneLists[storyView.story[@valueProperty]]
    insertIndex = 0
    storyViews.every (view) ->
      if (!storyView.story.isCurrent() and (view.backlogBanner or view.story.isCurrent())) or (storyView.story.epicColor > view.story.epicColor) or (storyView.story.id > view.story.id)
        insertIndex+=1
        true
      else
        false

    storyViews.splice(insertIndex, 0, storyView)
    @storyViewToDropZoneList[storyView.story.id] = storyViews

  ensureDropZone: (value) =>
    if value?
      while (value > @prevFib())
        @createNextDropZone()

  dropHandler: (event, newValue, storyId) =>
    @ensureDropZone(newValue)
    @storyViews[storyId].story.setProperty @valueProperty, newValue

  deconstruct: () =>
    @unobserveAll()
    $.map @storyViews, (view, id) =>
      @removeStoryView(view)
      view.deconstruct()
      delete @storyViews[id]

    $.map @dropZones, (zone, val) =>
      zone.deconstruct()
      delete @dropZones[val]

    @el.remove()
