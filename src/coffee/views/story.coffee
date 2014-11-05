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

    if !change? or change.name is "subset_epic"
      @el.removeClass (idx, css) ->
        (css.match(/(^|\s)epic-color-\S+/g) || []).join(' ')
      @el.addClass "epic-color-" + if @story.subset_epic? then @story.subset_epic.color else undefined

    if !change? or change.name is "isOpen"
      @el.find('.story-description')[if @story.isOpen then 'addClass' else 'removeClass']('show-me')

    # check all keys that start with visible
    if !change? or /^visible_/.test(change.name)
      @el[if @story.isVisible() then 'removeClass' else 'addClass']('hide-me')

    true

  deconstruct: () =>
    @unobserveAll()
    @el.off()
    @el.remove()
