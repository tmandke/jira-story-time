window.JiraStoryTime = window.JiraStoryTime or {}

window.JiraStoryTime.Story = class Story
  @id = "id"
  @description = "description"
  @summary = "summary"
  @business = "customfield_10003"
  @points = "customfield_10002"
  @epic = "customfield_10007"
  @NoPoints = "--"
  @devMode = true
  @autoUpdate = true

  @observer = (changes) ->
    changes.forEach (change) ->    
      # console.log(change.object.data.key + ": " + change.name + " was " + change.type + " to " + change.object[change.name]);
      change.object.render change.name

  toggelOpen: =>
    @isOpen = not @isOpen
    @linkedIssues.forEach (issue) =>
      if issue.story?
        if @isOpen
          issue.story.linkedStatus = issue.type
        else
          delete issue.story.linkedStatus

  
  constructor: (data) ->
    @data = data
    @linkedIssues = []
    @isOpen = false
    @id = @data.id
    @isCurrent = ($.inArray(@data.id, window.JiraStoryTime.Stories.current_stories) > -1)

  initialize: =>
    @key = @data.key
    @summary = @data.summary
    @points = @data.estimateStatistic.statFieldValue.value
    @getFullStory()
    if Story.autoUpdate is true
      @myInterval = setInterval(@getFullStory, 10000 + Math.random() * 5000)

    window.JiraStoryTime.Stories.updateEpics()
    
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
          @points = f.value or ""
          window.JiraStoryTime.Stories.updateEpics()

        when Story.business
          @business = (f.value or "")
        when Story.description
          @description = f.html
        when Story.epic
          @epicColor = window.JiraStoryTime.Stories.epicColor(f.text)

    @buildRelationShips()

  setPoints: (newPoints) =>
    @points = (if newPoints is Story.NoPoints then "" else newPoints)
    if Story.devMode is true
      console.log(this.key + ": Points would have been updated to " + newPoints)
    else
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
