class JiraStoryTime.Views.Subsets extends JiraStoryTime.Utils.Observer
  constructor: (@applicationState, @backlog) ->
    super()
    @el = $(JiraStoryTime.Utils.Templates.get('subsets.html'))
    @subsetViews = []
    @observe @applicationState
    @setUpSubsets()

  setUpSubsets: () =>
    @subsets = new JiraStoryTime.Models.Subsets(@backlog, @applicationState.subsets)
    @observe @subsets.subsets
    $.map @subsets.subsets, @addSubsetView

  tearDownSubsets: () =>
    @unobserve @subsets.subsets
    $.map @subsetViews, (sv) ->
      sv.deconstruct()
    @subsetViews = []
    @subsets.deconstruct()
    @subsets = null

  onObservedChange: (change) =>
    if change.object is @applicationState
      @tearDownSubsets()
      @setUpSubsets()
    else if change.object is @subsets.subsets and change.type is 'add'
      @addSubsetView(@subsets.subsets[change.name])

  addSubsetView: (subset) =>
    subsetView = new JiraStoryTime.Views.Subset(subset)
    @subsetViews.push(subsetView)
    @el.append subsetView.el

  deconstruct: () =>
    @tearDownSubsets()
    @unobserveAll()

