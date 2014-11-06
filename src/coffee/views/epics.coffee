class JiraStoryTime.Views.Subsets extends JiraStoryTime.Utils.Observer
  constructor: (@applicationState, @backlog) ->
    super()
    @el = $(JiraStoryTime.Utils.Templates.get('epics.html'))
    @subsetViews = []
    @observe @applicationState
    @setUpSubsets()

  setUpSubsets: () =>
    @subsets = new JiraStoryTime.Models.Subsets(@backlog, @applicationState.subsets)
    @observe @subsets.subsets
    $.map @subsets.subsets, @addEpicView

  tearDownSubsets: () =>
    @unobserve @subsets.subsets
    $.map @subsetViews, (sv) ->
      sv.deconstruct()

  onObservedChange: (change) =>
    if change.object is @applicationState
      @tearDownSubsets()
      @setUpSubsets()
    else if change.object is @subsets.subsets and change.type is 'add'
      @addEpicView(@subsets.subsets[change.name])

  addEpicView: (subset) =>
    subsetView = new JiraStoryTime.Views.Epic(subset)
    @subsetViews.push(subsetView)
    @el.append subsetView.el

  deconstruct: () =>
    @tearDownSubsets()
    @unobserveAll()

