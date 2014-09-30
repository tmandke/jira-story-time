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
    possiblePoints = [1,2,3,5,8,13,21]

    possiblePoints.forEach (points) ->
      $("#story_board").append window.JiraStoryTime.Templates['regularColumn.html']
      $("#story_board").children().last().attr "data-story-points", points
      $("#story_board").children().last().attr "id", "story-points-" + points
      $("#story_board").children().last().find(".story_board_row_points").html points

    @cols = document.querySelectorAll(".story_board_row")
    @undefinedCol = $("#story-points---")

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
      oldParent.removeClass "has-stories"  if oldParent.children('.story').length is 0
      # $("#story_board").css "min-width", ($(".has-stories").length * 300) + "px"
      @sortStoties($("#story-points-#{pts}"))
    else if change.name is "epicColor"
      @sortStoties(change.object.el.parent())

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
    $(this).find(".story_board_row_drop_mask").addClass "show-me"


  handleDragLeave: (e) ->
    e.stopPropagation()
    e.preventDefault()
    $(@parentElement).removeClass "over"
    $(this).removeClass "show-me"


  handleDrop: (e) =>
    # this / e.target is current target element.
    e.stopPropagation()  if e.stopPropagation # stops the browser from redirecting.

    newPoints = $(e.target).parents(".story_board_row")[0].getAttribute("data-story-points")
    @storyViews[e.dataTransfer.getData("storyId")].story.setPoints newPoints
    $(e.target).closest(".story_board_row_drop_mask").removeClass "show-me"

    # See the section on the DataTransfer object.
    false


  handleDragEnd: (e) =>
    # this/e.target is the source node.
    [].forEach.call @cols, (col) ->
      col.style.opacity = "1"
      col.classList.remove "over"


  dragSetup: =>
    @cols = document.querySelectorAll(".story_board_row")
    $.map @cols, (col) =>
      col.addEventListener "dragstart", @handleDragStart, false
      col.addEventListener "dragenter", @handleDragEnter, false
      col.addEventListener "dragover", @handleDragOver, false
      $(col).find(".story_board_row_drop_mask")[0].addEventListener "dragleave", @handleDragLeave, false
      $(col).find(".story_board_row_drop_mask")[0].addEventListener "drop", @handleDrop, false
      col.addEventListener "dragend", @handleDragEnd, false

  sortStoties: (el) =>
    listitems = el.children('.story').get()

    listitems.sort((a, b) =>
      storyA = @storyViews[$(a).attr('id')].story
      storyB = @storyViews[$(b).attr('id')].story
      diff = storyA.epicColor - storyB.epicColor
      if diff is 0 then storyA.key.localeCompare(storyB.key) else diff
    )

    $.each(listitems, (index, item) =>
      if(item.getAttribute('draggable') is "true")
        el.append(item)
      else
        $(item).insertBefore(el.find('.backlog'))
    )

