class JiraStoryTime.Views.Story extends JiraStoryTime.Utils.Observer
  constructor: (@story) ->
    super()
    @observe @story
    @el = $(JiraStoryTime.Utils.Templates.get('storyCard.html'))
    @el.attr "data-story-id", @story.id
    @el.attr "id", "story-" + @story.id
    @el.on 'click', @story.toggelOpen
    @render()

  onObservedChange: (change) =>
    if change.object is @story
      @render(change)

  _present_points: (points) ->
    if points then points else "_"

  render: (change) =>
    ['points', 'business'].forEach (field) =>
      if !change? or change.name == field
        @el.find(".story-#{field}").html(@_present_points(@story[field]))

    ['key', 'summary', 'description'].forEach (field) =>
      if !change? or change.name == field
        @el.find(".story-#{field}").html(@story[field])

    if !change? or change.name is 'isCurrent'
      @el.attr "draggable", not @story.isCurrent

    if !change? or change.name is "epicColor"
      @el.removeClass "epic-color-*"
      @el.addClass "epic-color-" + @story.epicColor

    if !change? or change.name is "isOpen"
      @el.find('.story-description')[if @story.isOpen then 'addClass' else 'removeClass']('show-me')

    true

  deconstruct: () =>
    @unobserveAll()
    @el.off()
    @el.remove()
