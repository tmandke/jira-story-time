class JiraStoryTime.Models.Story extends JiraStoryTime.Utils.Observer
  @_fieldIds =
    id: "id"
    key: "issuekey"
    description: "description"
    summary: "summary"
    business: "customfield_10003"
    points: "customfield_10002"
    epic: "customfield_10007"

  isCurrent: false
  isOpen: false

  constructor: (@basicData, @rapidView, @applicationState) ->
    super()
    @id = @basicData.id
    @observe(@applicationState)
    @getFullStory()
    @updateState()

  onObservedChange: (change) =>
    if change.object is @applicationState
      @updateState()

  updateIsCurrent: (currentIssues) =>
    @isCurrent = currentIssues.indexOf(@id) > -1

  toggelOpen: =>
    @isOpen = not @isOpen

  updateState: =>
    if @applicationState.autoUpdate is true
      unless @autoUpdateInterval?
        @autoUpdateInterval = setInterval(@getFullStory, 10000 + Math.random() * 5000)
    else
      if @autoUpdateInterval?
        clearInterval @autoUpdateInterval
        delete @autoUpdateInterval

    @serverSync = @applicationState.serverSync

  getFullStory: =>
    $.ajax(
      url: "/rest/greenhopper/1.0/xboard/issue/details.json?" +
        "issueIdOrKey=#{@id}&loadSubtasks=true&rapidViewId=#{@rapidView}"
      context: this
    ).done @setMoreData

  setMoreData: (data) =>
    @moreData = data
    data.fields.forEach (f) =>
      switch f.id
        when @constructor._fieldIds.key
          @key = f.text
        when @constructor._fieldIds.summary
          @summary = f.text
        when @constructor._fieldIds.points
          @points = f.value or ""
        when @constructor._fieldIds.business
          @business = f.value or ""
        when @constructor._fieldIds.description
          @description = f.html
        when @constructor._fieldIds.epic
          @epic = f.text

  deconstruct: =>
    clearInterval @autoUpdateInterval
    delete @autoUpdateInterval
    @unobserveAll()
