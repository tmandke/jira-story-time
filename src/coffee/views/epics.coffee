class JiraStoryTime.Views.Epics extends JiraStoryTime.Utils.Observer
  constructor: (@epics) ->
    super()
    @el = $(JiraStoryTime.Utils.Templates.get('epics.html'))
    @epicViews = []
    @observe @epics.epics
    $.map @epics.epics, @addEpicView

  onObservedChange: (change) =>
    if change.type is 'add'
      @addEpicView(@epics.epics[change.name])

  addEpicView: (epic) =>
    epicView = new JiraStoryTime.Views.Epic(epic)
    @epicViews.push(epicView)
    @el.append epicView.el

  deconstruct: () =>
    @unobserveAll()
    $.map @epicViews, (epicView) ->
      epicView.deconstruct()

