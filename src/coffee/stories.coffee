window.JiraStoryTime = window.JiraStoryTime or {}
window.JiraStoryTime.Stories = class Stories
  @current_stories = []
  @backlog_stories = {}
  
  @fetchStories: =>
    params = window.JiraStoryTime.Util.deparam(location.href.split("?")[1])
    @rapidView = params["rapidView"]
    $.ajax
      url: "/rest/greenhopper/1.0/xboard/plan/backlog/data.json?rapidViewId=" + @rapidView,
      context: document.body,
      success: @parseStories
      

  @parseStories: (response) =>
    @backlog_stories = {}
    @current_stories = $.map response.sprints, (sprint) ->
      if sprint.state is "ACTIVE" then sprint.issuesIds else null
    
    response.issues.forEach (s) =>
      if s.typeName is "Story"
        @backlog_stories[s.key] = new window.JiraStoryTime.Story(s)

  @epics: []
  @epicColor: (epic) =>
    color = $.inArray(epic, window.JiraStoryTime.Stories.epics)
    color = @addEpic(epic)  if color < 0
    color


  @addEpic: (epic) =>
    color = window.JiraStoryTime.Stories.epics.length
    window.JiraStoryTime.Stories.epics.push (if epic is "None" then "" else epic)
    $("#story_board_epics").append window.JiraStoryTime.Templates['epic.html']
    children = $("#story_board_epics").children()
    dom = children[children.length - 1]
    $(dom).find(".epic-name").html epic
    dom.setAttribute "id", "epic-" + color
    $(dom).addClass "epic-color-" + color
    color

  @resetEpics: =>
    @epics = []


  @updateEpics: =>
    epicPoints = {}
    type = if $('#pointsType-sp').prop('checked') then 'points' else 'business'
    $.map @backlog_stories, (s) ->
      epicPoints[s.epicColor or 0] = (epicPoints[s.epicColor or 0] or 0) + parseInt(s[type] or 0)

    $.map epicPoints, (v, k) ->
      $("#epic-" + k).find(".story-points").html v
