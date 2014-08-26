window.JiraStoryTime = window.JiraStoryTime or {}

window.JiraStoryTime.Story = class Story
  @id = "id"
  @description = "description"
  @summary = "summary"
  @business = "customfield_10003"
  @points = "customfield_10002"
  @epic = "customfield_10007"
  @NoPoints = "--"
  @devMode = false
  @autoUpdate = true

  @observer = (changes) ->
    changes.forEach (change) ->    
      # console.log(change.object.data.key + ": " + change.name + " was " + change.type + " to " + change.object[change.name]);
      change.object.render change.name

  
  constructor: (data) ->
    @data = data
    @linkedIssues = []
    @isOpen = false
      
      
  initialize: (el) =>
    el.append window.JiraStoryTime.Templates.boardStory
    dom = el[0].lastChild
    dom.setAttribute "data-story-id", @data.id
    dom.setAttribute "id", "story-" + @data.id
    @isCurrent = ($.inArray(@data.id, window.JiraStoryTime.Stories.current_stories) > -1)
    dom.setAttribute "draggable", not @isCurrent
    $(dom).click =>
      if @isOpen
        @closeCard(dom)
      else
        @openCard(dom)
      
    $(dom).on "pointsChanged", this, (e, newPoints) ->
      e.data.setPoints newPoints

    Object.observe this, Story.observer
    @id = @data.id
    @key = @data.key
    @summary = @data.summary
    @points = @data.estimateStatistic.statFieldValue.value
    @getFullStory()
    if Story.autoUpdate is true
      @myInterval = setInterval(@getFullStory, 10000 + Math.random() * 5000)
    
  
    
    
  getFullStory: =>
    $.ajax(
      url: "/rest/greenhopper/1.0/xboard/issue/details.json?issueIdOrKey=" + @id + "&loadSubtasks=true&rapidViewId=" + window.JiraStoryTime.Stories.rapidView
      context: this
    ).done @setMoreData
    
    
  setMoreData: (data) =>
    @moreData = data
    data.fields.forEach (f) =>
      switch f.id
        when Story.summary
          @summary = f.value
        when Story.points
          @setPoints f.value or ""
        when Story.business
          @business = (f.value or "")
        when Story.description
          @description = f.html
        when Story.epic
          @epicColor = window.JiraStoryTime.Stories.epicColor(f.text)

    @buildRelationShips()
    
    
  render: (changed_field) =>
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


  setPoints: (newPoints) =>
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
    
    
  buildRelationShips: =>
    @linkedIssues = []
    @moreData.issueLinks.issueLinkTypeEntries.forEach (typeEntry) =>
      issueType = typeEntry.relationship
      if issueType is "is blocked by"
        issueType = "Blocker"
      else issueType = "Frees"  if issueType is "blocks"
      typeEntry.issueLinkEntries.forEach (issue) =>
        @linkedIssues.push
          type: issueType
          story: window.JiraStoryTime.Stories.backlog_stories[issue.title]
          key: issue.title
          
  close: =>
    clearInterval @myInterval
    
    
  openCard: (dom)=>
    @isOpen = true
    $(dom).find('.story-description').show()
    @linkedIssues.forEach (issue) =>
      issue.story.linkedStatus = issue.type  if issue.story?
      
    
  closeCard: (dom)=>
    @isOpen = false
    $(dom).find('.story-description').hide()
    @linkedIssues.forEach (issue) =>
      delete issue.story.linkedStatus  if issue.story?
  

