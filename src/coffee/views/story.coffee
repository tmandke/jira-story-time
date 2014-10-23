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

  _presentPoints: (points) ->
    if points then points else "_"

  render: (change) =>
    ['points', 'business'].forEach (field) =>
      if !change? or change.name == field
        @el.find(".story-#{field}").html(@_presentPoints(@story[field]))

    ['key', 'summary', 'description'].forEach (field) =>
      if !change? or change.name == field
        @el.find(".story-#{field}").html(@story[field])

    if !change? or change.name is 'isCurrent'
      @el.attr "draggable", not @story.isCurrent

    if !change? or change.name is "epicColor"
      @el.removeClass (idx, css) ->
        (css.match(/(^|\s)epic-color-\S+/g) || []).join(' ')
      @el.addClass "epic-color-" + @story.epicColor

    if !change? or change.name is "isOpen"
      @el.find('.story-description')[if @story.isOpen then 'addClass' else 'removeClass']('show-me')

    if !change? or change.name is "visible"
      @el[if @story.visible then 'removeClass' else 'addClass']('hide-me')

    true

  deconstruct: () =>
    @unobserveAll()
    @el.off()
    @el.remove()
