class JiraStoryTime.Views.DropZone extends JiraStoryTime.Utils.Observer
  constructor: (@storyViews, @value, @dropHandler) ->
    super()
    @observe @storyViews
    @el = $(window.JiraStoryTime.Utils.Templates.get('regularColumn.html'))
    @el.attr "data-story-points", @value
    @el.attr "id", "story-points-#{@value}"
    @el.find(".strory-drop-zone-points").html @value

    @el.on "dragstart", @handleDragStart
    @el.on "dragenter", @handleDragEnter
    @el.find(".strory-drop-zone-mask").on "dragover", @handleDragOver
    @el.find(".strory-drop-zone-mask").on "dragleave", @handleDragLeave
    @el.find(".strory-drop-zone-mask").on "drop", @handleDrop

    @storyViews.forEach (view) =>
      @el.find('.stories').append(view.el)

  onObservedChange: (change) =>
    change.removed.forEach (view) =>
      if @el.has(view.el).length > 0
        view.el.remove()
    if change.addedCount > 0
      for i in [0..change.addedCount-1] by 1
        insertBeforeElement = @el.find('.story-item')[i + change.index]
        if insertBeforeElement?
          @storyViews[i + change.index].el.insertBefore(insertBeforeElement)
        else
          @el.find('.stories').append(@storyViews[i + change.index].el)

  handleDragStart: (e) ->
    e.originalEvent.dataTransfer.setData "storyId", $(e.target).closest(".story").attr('data-story-id')

  handleDragEnter: (e) =>
    @el.addClass "over"

  handleDragOver: (e) ->
    e.preventDefault()

  handleDragLeave: (e) =>
    @el.removeClass "over"

  handleDrop: (e) =>
    @el.removeClass "over"
    storyId = e.originalEvent.dataTransfer.getData("storyId")
    @dropHandler e, @value, storyId
    # See the section on the DataTransfer object.
    false

  deconstruct: () =>
    @unobserveAll()
    @el.off()
    @el.find(".strory-drop-zone-mask").off()
    @el.remove()
