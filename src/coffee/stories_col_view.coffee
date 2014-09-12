window.JiraStoryTime ||= {}

class window.JiraStoryTime.StoriesColView
  constructor: (stories, type) ->
    @setupColumns()
    @storyViews = {}
    $.map stories, (s) =>
      view = new window.JiraStoryTime.StoryView(s, @undefinedCol)
      s.initialize()
      Object.observe view, @pointsUpdateObserver
      @storyViews["story-" + s.id] = view
    @type = type
    @dragSetup()

  setupColumns: =>
    possiblePoints = [1,2,3,5,8,13,21,window.JiraStoryTime.Story.NoPoints]
    
    possiblePoints.forEach (points) ->
      $("#story_board").append window.JiraStoryTime.Templates['regularColumn.html']
      $("#story_board").children().last().attr "data-story-points", points
      $("#story_board").children().last().attr "id", "story-points-" + points
      $("#story_board").children().last().find(".story_board_row_points").html points

    @cols = document.querySelectorAll("#story_board .story_board_row")
    @undefinedCol = $("#story_board").children().last()

  pointsUpdateObserver: (changes) =>
    changes.forEach (change) =>    
      # console.log(change.object.data.key + ": " + change.name + " was " + change.type + " to " + change.object[change.name]);
      @render change

  render: (change) =>
    view = change.object
    if change.name is @type
      pts = (if view[@type] is "" then window.JiraStoryTime.Story.NoPoints else view[@type])
      $("#story-points-" + pts).addClass "has-stories"
      oldParent = view.el.parents(".story_board_row")
      view.el[if view.story.isCurrent then "insertBefore" else "insertAfter"]("#story-points-#{pts} .backlog")
      oldParent.removeClass "has-stories"  if oldParent.find(".backlog-stories").children().length is 0 and oldParent.find(".current-stories").children().length is 0
      # $("#story_board").css "min-width", ($(".has-stories").length * 300) + "px"

  close: =>
    $.map @storyViews, (sv) ->
      Object.unobserve sv, @pointsUpdateObserver
      sv.close
  
  handleDragStart: (e) ->
    @style.opacity = "0.4" # this / e.target is the source node.
    e.dataTransfer.setData "storyId", $(e.target).closest(".story")[0].getAttribute("id")


  handleDragOver: (e) ->
    e.preventDefault()  if e.preventDefault # Necessary. Allows us to drop.
    false


  handleDragEnter: (e) ->    
    # this / e.target is the current hover target.
    @classList.add "over"
    $(this).find(".story_board_row_drop_mask").show()


  handleDragLeave: (e) ->
    e.stopPropagation()
    e.preventDefault()
    $(@parentElement).removeClass "over"
    $(this).hide()


  handleDrop: (e) =>
    # this / e.target is current target element.
    e.stopPropagation()  if e.stopPropagation # stops the browser from redirecting.
    
    newPoints = e.target.parentElement.getAttribute("data-story-points")
    @storyViews[e.dataTransfer.getData("storyId")].story.setPoints newPoints
    $(e.target).hide()
    
    # See the section on the DataTransfer object.
    false


  handleDragEnd: (e) =>
    # this/e.target is the source node.
    [].forEach.call @cols, (col) ->
      col.style.opacity = "1"
      col.classList.remove "over"


  dragSetup: =>
    @cols = document.querySelectorAll("#story_board .story_board_row")
    $.map @cols, (col) =>
      col.addEventListener "dragstart", @handleDragStart, false
      col.addEventListener "dragenter", @handleDragEnter, false
      col.addEventListener "dragover", @handleDragOver, false
      $(col).find(".story_board_row_drop_mask")[0].addEventListener "dragleave", @handleDragLeave, false
      $(col).find(".story_board_row_drop_mask")[0].addEventListener "drop", @handleDrop, false
      col.addEventListener "dragend", @handleDragEnd, false
