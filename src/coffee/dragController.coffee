window.JiraStoryTime = window.JiraStoryTime or {}
window.JiraStoryTime.DragController =
  handleDragStart: (e) ->
    @style.opacity = "0.4" # this / e.target is the source node.
    e.dataTransfer.setData "storyId", $(e.target).closest(".story")[0].getAttribute("id")
    return

  handleDragOver: (e) ->
    e.preventDefault()  if e.preventDefault # Necessary. Allows us to drop.
    false

  handleDragEnter: (e) ->
    
    # this / e.target is the current hover target.
    @classList.add "over"
    $(this).find(".story_board_row_drop_mask").show()
    return

  handleDragLeave: (e) ->
    e.stopPropagation()
    e.preventDefault()
    $(@parentElement).removeClass "over"
    $(this).hide()
    return

  handleDrop: (e) ->
    
    # this / e.target is current target element.
    e.stopPropagation()  if e.stopPropagation # stops the browser from redirecting.
    newPoints = @parentElement.getAttribute("data-story-points")
    $("#" + e.dataTransfer.getData("storyId")).trigger "pointsChanged", [newPoints]
    $(e.target).hide()
    
    # See the section on the DataTransfer object.
    false

  handleDragEnd: (e) ->
    
    # this/e.target is the source node.
    [].forEach.call window.JiraStoryTime.DragController.cols, (col) ->
      col.style.opacity = "1"
      col.classList.remove "over"
      return

    return

  setup: ->
    @cols = document.querySelectorAll("#story_board .story_board_row")
    _this = this
    [].forEach.call @cols, (col) ->
      col.addEventListener "dragstart", _this.handleDragStart, false
      col.addEventListener "dragenter", _this.handleDragEnter, false
      col.addEventListener "dragover", _this.handleDragOver, false
      $(col).find(".story_board_row_drop_mask")[0].addEventListener "dragleave", _this.handleDragLeave, false
      $(col).find(".story_board_row_drop_mask")[0].addEventListener "drop", _this.handleDrop, false
      col.addEventListener "dragend", _this.handleDragEnd, false
      return

    return