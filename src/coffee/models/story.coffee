class JiraStoryTime.Models.Story extends JiraStoryTime.Utils.Observer
  @_fieldIds =
    sprintState: "sprint"
    epic: "epic"

  @_fieldLabels =
    "Description": "description"
    "Summary": "summary"
    "Fix Version/s": "version"
    "Business Value": "business"
    "Story Points": "points"


  isOpen: false
  visible_default: true

  @initFieldIds: ->
    $.ajax(
      url: "/rest/api/2/field"
      context: this
    ).done @_initFieldIds

  @_initFieldIds: (data) ->
    data.forEach (f) ->
      if (JiraStoryTime.Models.Story._fieldLabels[f.name]?)
        JiraStoryTime.Models.Story._fieldIds[JiraStoryTime.Models.Story._fieldLabels[f.name]] = f.id
    console.log(JiraStoryTime.Models.Story._fieldIds)

  constructor: (@basicData, @rapidView, @applicationState) ->
    super()
    @id = @basicData.id
    @key = @basicData.key
    @observe(@applicationState)
    @setMoreData(@basicData)
    @updateState()

  onObservedChange: (change) =>
    if change.object is @applicationState
      @updateState()

  isCurrent: =>
    (@sprintState? and @sprintState == "active")

  toggelOpen: =>
    @isOpen = not @isOpen

  updateState: =>
    @serverSync = @applicationState.serverSync

  setMoreData: (data) =>
    @moreData = data
    $.each data.fields, (fieldId, value) =>
      switch fieldId
        when @constructor._fieldIds.summary
          @summary = value
        when @constructor._fieldIds.sprintState
          @sprintState = value.state
        when @constructor._fieldIds.description
          @description = value
        when @constructor._fieldIds.version
          @version = if value[0]? then value[0].name else value[0]
        when @constructor._fieldIds.points
          @points = @_parsePoints value
        when @constructor._fieldIds.business
          @business = @_parsePoints value
        when @constructor._fieldIds.epic
          @epic = value.name

  setProperty: (prop, points) =>
    @[prop] = points
    if @serverSync
      data =
        update:
          "#{JiraStoryTime.Models.Story._fieldIds[prop]}" : [
            set: points
          ]
      $.ajax(
        url: "/rest/api/2/issue/#{@key}"
        context: this
        type: "PUT"
        data: JSON.stringify data
        beforeSend: (request) ->
          request.setRequestHeader("Content-Type", "application/json")
          request.setRequestHeader("Accept", "application/json")
      )

    else
      console.log("#{@key}: #{prop} would have been updated to #{points}")

  isVisible: () =>
    vis = true
    Object.keys(@).forEach (k) =>
      if /^visible/.test(k)
        vis = vis && @[k]
      true
    vis

  _parsePoints: (text) ->
    ret = parseInt text
    if ret then ret else undefined

  deconstruct: =>
    @unobserveAll()
