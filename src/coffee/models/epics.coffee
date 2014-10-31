class JiraStoryTime.Models.Epics extends JiraStoryTime.Utils.Observer

  constructor: (@backlog) ->
    super()
    @epics = {}
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

    else if change.name is 'epic'
      @setEpicColorAndVisibility(change.object)

  setEpicColorAndVisibility: (story) =>
    epicName = if !story.epic or story.epic is "" then "None" else story.epic
    unless @epics[epicName]?
      @epics[epicName] = new JiraStoryTime.Models.Epic epicName, Object.keys(@epics).length + 1, @backlog.stories
    story.epicColor = @epics[epicName].color
    story.visible = @epics[epicName].visible
    story.epicObj = @epics[epicName]

  deconstruct: () =>
    @unobserveAll()
    $.map @epics, (epic) ->
      epic.deconstruct()
