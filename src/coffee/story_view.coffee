window.JiraStoryTime ||= {}

class window.JiraStoryTime.StoryView
  constructor: (story, parent) ->
    @story = story
    parent.append window.JiraStoryTime.Templates['storyCard.html']
    @el = $(parent.children()[parent.children().length - 1])
    @el.attr "data-story-id", @story.id
    @el.attr "id", "story-" + @story.id
    @el.attr "draggable", not @story.isCurrent
    @el.on 'click', =>
      @story.toggelOpen

    Object.observe @story, @observer

  observer: (changes) =>
    $.map changes, (change) =>    
      # console.log(change.object.data.key + ": " + change.name + " was " + change.type + " to " + change.object[change.name]);
      @render change
      true

  render: (change) =>
    @el.find(".story-" + change.name).html @story[change.name]
    
    if change.name is "linkedStatus"
      @el.attr "data-content", @story.linkedStatus
      if change.type == 'delete'
        @el.removeClass "linked-story story-blocker story-frees"
      else
        @el.addClass "linked-story"
        if @story.linkedStatus is "Blocker"
          @el.addClass "story-blocker"
        if @story.linkedStatus is "Frees"
          @el.addClass "story-frees"

    if change.name is "epicColor"
      @el.addClass "epic-color-" + @story.epicColor 

    if change.name is "isOpen"
      @el.find('.story-description')[if @story.isOpen then 'addClass' else 'removeClass']('show-me')
    
    @points = @story.points if change.name is "points"
    @buisness = @story.buisness if change.name is "buisness"
    true

  close: =>
    Object.unobserve @story, @observer
    @el.off()
