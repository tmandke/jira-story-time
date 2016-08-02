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
      url: "/rest/agile/1.0/board/#{@rapidView}/issue/"
      context: document.body
    ).done @parseResponse

  parseResponse: (response)=>
    @_updateStoriesHash(response)

  _updateStoriesHash: (response) =>
    newSetOfStories = []
    response.issues.forEach (s) =>
      newSetOfStories.push(s.id.toString())
      unless @stories[s.id]?
        @stories[s.id] = new JiraStoryTime.Models.Story s, @rapidView, @applicationState

    $(Object.keys(@stories)).filter( (idx, id)->
      newSetOfStories.indexOf(id) is -1
    ).map (idx, storyId) =>
      @stories[storyId].deconstruct()
      delete @stories[storyId]

  deconstruct: =>
    clearInterval @autoUpdateInterval
    delete @autoUpdateInterval
    @unobserveAll()
    $.map @stories, (story, id) =>
      story.deconstruct()
      delete @stories[id]
