window.JiraStoryTime = window.JiraStoryTime or {}
Story = (data) ->
  @data = data
  @linkedIssues = []
  return

Story.id = "id"
Story.description = "description"
Story.summary = "summary"
Story.business = "customfield_10003"
Story.points = "customfield_10002"
Story.epic = "customfield_10007"
Story.NoPoints = "--"
Story.devMode = false
Story.autoUpdate = true
Story::getFullStory = ->
  $.ajax(
    url: "/rest/greenhopper/1.0/xboard/issue/details.json?issueIdOrKey=" + @id + "&loadSubtasks=true&rapidViewId=" + window.JiraStoryTime.Stories.rapidView
    context: this
  ).done @setMoreData

Story::setMoreData = (data) ->
  @moreData = data
  _this = this
  data.fields.forEach (f) ->
    switch f.id
      when Story.summary
        _this.summary = f.value
      when Story.points
        _this.setPoints f.value or ""
      when Story.business
        _this.business = (f.value or "")
      when Story.description
        _this.description = f.html
      when Story.epic
        _this.epicColor = window.JiraStoryTime.Stories.epicColor(f.text)

  @buildRelationShips()
  return

Story::render = (changed_field) ->
  el = $("#story-" + @data.id)
  col = el.parent().parent()
  el.find(".story-" + changed_field).html this[changed_field]
  if changed_field is "linkedStatus"
    el.attr "data-content", @linkedStatus
    action = ((if not @linkedStatus? then "removeClass" else "addClass"))
    el[action] "linked-story"
    if @linkedStatus is "Blocker"
      el[action] "story-blocker"
    else el[action] "story-frees"  if @linkedStatus is "Frees"
  el.addClass "epic-color-" + @epicColor  if changed_field is "epicColor"
  if changed_field is "points"
    pts = (if @points is "" then Story.NoPoints else @points)
    $("#story-points-" + pts).addClass "has-stories"
    $("#story-points-" + pts).find((if @isCurrent then ".current-stories" else ".backlog-stories")).append el
    col.removeClass "has-stories"  if col.find(".backlog-stories").children().length is 0 and col.find(".current-stories").children().length is 0
    $("#story_board").css "min-width", ($(".has-stories").length * 300) + "px"
  return

Story::setPoints = (newPoints) ->
  @points = (if newPoints is Story.NoPoints then "" else newPoints)
  unless Story.devMode is true
    $.ajax(
      url: "/rest/greenhopper/1.0/xboard/issue/update-field.json"
      context: document.body
      type: "PUT"
      headers:
        "Content-Type": "application/json"

      data: "{\"fieldId\": \"" + Story.points + "\", \"issueIdOrKey\": " + @id + ", \"newValue\": \"" + @points + "\"}"
    ).done (response) ->
      console.log response
      return

  window.JiraStoryTime.Stories.updateEpics()
  return

Story::buildRelationShips = ->
  _this = this
  @linkedIssues = []
  @moreData.issueLinks.issueLinkTypeEntries.forEach (typeEntry) ->
    issueType = typeEntry.relationship
    if issueType is "is blocked by"
      issueType = "Blocker"
    else issueType = "Frees"  if issueType is "blocks"
    typeEntry.issueLinkEntries.forEach (issue) ->
      _this.linkedIssues.push
        type: issueType
        story: window.JiraStoryTime.Stories.backlog_stories[issue.title]
        key: issue.title

      return

    return

  return

Story::initialize = (el) ->
  _this = this
  el.append window.JiraStoryTime.Templates.boardStory
  dom = el[0].lastChild
  dom.setAttribute "data-story-id", @data.id
  dom.setAttribute "id", "story-" + @data.id
  @isCurrent = ($.inArray(@data.id, window.JiraStoryTime.Stories.current_stories) > -1)
  dom.setAttribute "draggable", not @isCurrent
  $(dom).hover (->
    _this.linkedIssues.forEach (issue) ->
      issue.story.linkedStatus = issue.type  if issue.story?
      return

    return
  ), ->
    _this.linkedIssues.forEach (issue) ->
      delete issue.story.linkedStatus  if issue.story?
      return

    return

  $(dom).on "pointsChanged", this, (e, newPoints) ->
    e.data.setPoints newPoints
    return

  Object.observe this, Story.observer
  @id = @data.id
  @key = @data.key
  @summary = @data.summary
  @points = @data.estimateStatistic.statFieldValue.value
  @getFullStory()
  if Story.autoUpdate is true
    @myInterval = setInterval(->
      _this.getFullStory()
      return
    , 10000 + Math.random() * 5000)
  return

Story::close = ->
  clearInterval @myInterval
  return

Story.observer = (changes) ->
  changes.forEach (change) ->
    
    # console.log(change.object.data.key + ": " + change.name + " was " + change.type + " to " + change.object[change.name]);
    change.object.render change.name
    return

  return

window.JiraStoryTime.Story = Story