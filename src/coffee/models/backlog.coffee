class JiraStoryTime.Models.Backlog extends JiraStoryTime.Utils.Observer
  stories: {}
  issues: {}
  constructor: (@rapidView, @applicationState) ->
    super()
    @observe(@applicationState)
    @updateState()
    @updateBacklog()

  onObservedChange: (change) =>
    if change.object is @applicationState
      @updateState()
    else if change.name is 'type'
      if change.object.type is 'Story'
        @stories[change.object.id] = change.object
      else
        delete @stories[change.object.id]

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
    @_updateIssuesHash(response)
    @_updateCurrentStatusOfIssues(response)

  _updateIssuesHash: (response) =>
    newSetOfIssues = []
    response.issues.forEach (s) =>
      newSetOfIssues.push(s.id.toString())
      unless @issues[s.id]?
        issue = new JiraStoryTime.Models.Issue s, @rapidView, @applicationState
        @issues[issue.id] = issue
        @observe issue
        if issue.type is "Story"
          @stories[issue.id] = issue

    $(Object.keys(@issues)).filter( (idx, id)->
      newSetOfIssues.indexOf(id) is -1
    ).map (idx, issueId) =>
      @unobserve @issues[issueId]
      @issues[issueId].deconstruct()
      delete @issues[issueId]
      delete @stories[issueId]

  _updateCurrentStatusOfIssues: (response) =>
    currentIssues = $.map(response.sprints, (sprint) ->
      if sprint.state is "ACTIVE" then sprint.issuesIds else null
    )

    $.map @issues, (issue, id) =>
      @issues[id].updateIsCurrent(currentIssues)

  deconstruct: =>
    clearInterval @autoUpdateInterval
    delete @autoUpdateInterval
    @unobserveAll()
    $.map @issues, (issue, id) =>
      issue.deconstruct()
      delete @issues[id]
      delete @stories[id]
