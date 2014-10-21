class JiraStoryTime.Views.DropZone extends JiraStoryTime.Utils.Observer
  constructor: (@storyViews, @value, @dropHandler) ->
    super()
    @observe @storyViews
    @el = $(window.JiraStoryTime.Utils.Templates.get('regularColumn.html'))
    @el.attr "data-story-points", @value
    @el.attr "id", "story-points-#{@value}"
    @el.find(".story_board_row_points").html @value

    @el.on "dragstart", @handleDragStart
    @el.on "dragenter", @handleDragEnter
    @el.on "dragover", @handleDragOver
    @el.find(".story_board_row_drop_mask").on "dragleave", @handleDragLeave
    @el.find(".story_board_row_drop_mask").on "drop", @handleDrop

    @storyViews.forEach (view) =>
      @el.find('.stories').append(view.el)

  onObservedChange: (change) =>
    change.removed.forEach (view) =>
      if @el.has(view.el).length > 0
        view.el.remove()
    if change.addedCount > 0
      for i in [0..change.addedCount-1]
        insertBeforeElement = @el.find('.story-item')[i + change.index]
        if insertBeforeElement?
          @storyViews[i + change.index].el.insertBefore(insertBeforeElement)
        else
          @el.find('.stories').append(@storyViews[i + change.index].el)

  handleDragStart: (e) =>
    e.originalEvent.dataTransfer.setData "storyId", $(e.target).closest(".story").attr('data-story-id')

  handleDragOver: (e) ->
    e.preventDefault()  if e.preventDefault # Necessary. Allows us to drop.
    false


  handleDragEnter: (e) =>
    # this / e.target is the current hover target.
    @el.addClass "over"

  handleDragLeave: (e) =>
    e.stopPropagation()
    e.preventDefault()
    @el.removeClass "over"

  handleDrop: (e) =>
    @el.removeClass "over"
    # this / e.target is current target element.
    e.stopPropagation()  if e.stopPropagation # stops the browser from redirecting.

    newValue = @value
    storyId = e.originalEvent.dataTransfer.getData("storyId")
    @dropHandler e, newValue, storyId
    # See the section on the DataTransfer object.
    false
