class JiraStoryTime.Models.Backlog extends JiraStoryTime.Utils.Observer
  stories: {}
  constructor: (@rapidView, @applicationState) ->
    super()
    @observe(@applicationState)
    @updateState()
    @updateBacklog()

  onObservedChange: (change) =>
    if change.object is @applicationState
      @updateState()

  updateState: =>
    if @applicationState.autoUpdate is true
      unless @autoUpdateInterval?
        @autoUpdateInterval = setInterval(@updateBacklog, 10000 + Math.random() * 5000)
    else
      if @autoUpdateInterval?
        clearInterval @autoUpdateInterval
        delete @autoUpdateInterval

  updateBacklog: =>
    $.ajax(
      url: "/rest/greenhopper/1.0/xboard/plan/backlog/data.json?rapidViewId=" + @rapidView
      context: document.body
    ).done @parseResponse

  parseResponse: (response)=>
    @_updateStoriesHash(response)
    @_updateCurrentStatusOfStories(response)

  _updateStoriesHash: (response) =>
    newSetOfStories = []
    response.issues.forEach (s) =>
      if s.typeName is "Story"
        newSetOfStories.push(s.id.toString())
        unless @stories[s.id]?
          @stories[s.id] = new JiraStoryTime.Models.Story s, @rapidView, @applicationState

    $(Object.keys(@stories)).filter( (idx, id)->
      newSetOfStories.indexOf(id) is -1
    ).map (idx, storyId) =>
      @stories[storyId].deconstruct()
      delete @stories[storyId]

  _updateCurrentStatusOfStories: (response) =>
    currentIssues = $.map(response.sprints, (sprint) ->
      if sprint.state is "ACTIVE" then sprint.issuesIds else null
    )

    $.map @stories, (story, id) =>
      @stories[id].updateIsCurrent(currentIssues)

  deconstruct: =>
    clearInterval @autoUpdateInterval
    delete @autoUpdateInterval
    @unobserveAll()
    $.map @stories, (story, id) =>
      story.deconstruct()
      delete @stories[id]
