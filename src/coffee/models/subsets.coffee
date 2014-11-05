class JiraStoryTime.Models.Subsets extends JiraStoryTime.Utils.Observer

  constructor: (@backlog, @subsetVar) ->
    super()
    @subsets = {}
    @observe @backlog.stories
    $.map @backlog.stories, (s)=>
      @observe s
    $.map @backlog.stories, @setEpicColorAndVisibility

  onObservedChange: (change) =>
    if change.object is @backlog.stories
      if change.type is 'add'
        @observe change.object[change.name]
        @setEpicColorAndVisibility(change.object[change.name])
      else if change.type is 'delete'
        @unobserve change.object[change.name]

    else if change.name is @subsetVar
      @setEpicColorAndVisibility(change.object)

  setEpicColorAndVisibility: (story) =>
    subsetName = if !story[@subsetVar] or story[@subsetVar] is "" then "None" else story[@subsetVar]
    unless @subsets[subsetName]?
      @subsets[subsetName] = new JiraStoryTime.Models.Subset @subsetVar, subsetName, Object.keys(@subsets).length + 1, @backlog.stories
    story["subset_#{@subsetVar}"] = @subsets[subsetName]

  deconstruct: () =>
    @unobserveAll()
    $.map @subsets, (subset) ->
      subset.deconstruct()
