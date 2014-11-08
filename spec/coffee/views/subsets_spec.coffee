describe 'Views.Subsets', ->
  appState = null
  backlog = null
  subsetsView = null
  modelSubsetsDeconstruct = null

  beforeEach ->
    appState = new JiraStoryTime.Models.ApplicationState()
    backlog = {}
    modelSubsetsDeconstruct = jasmine.createSpy('subsets.deconstruct')
    spyOn(JiraStoryTime.Models, 'Subsets').and.callFake((backlog, subsetVar) ->
      ret =
        subsets: {}
        deconstruct: modelSubsetsDeconstruct
      ret.subsets["ss1-#{subsetVar}"] =
        name: "ss1-#{subsetVar}"
        points: 1
        business: 2
        color: 1
      ret.subsets["ss2-#{subsetVar}"] =
        name: "ss2-#{subsetVar}"
        points: 4
        business: 7
        color: 2
      ret
    )
    subsetsView = new JiraStoryTime.Views.Subsets(appState, backlog)
    setFixtures(subsetsView.el)

  afterEach ->
    subsetsView.deconstruct()

  describe '.constructor', ->
    it 'creates 2 subset views', ->
      expect(subsetsView.el.find('input').length).toBe 2
      expect(subsetsView.el).toContainText('version')

    it 'observes application state', ->
      appState.subsets = 'epic'
      Object.deliverChangeRecords subsetsView.observer
      expect(modelSubsetsDeconstruct).toHaveBeenCalled()
      expect(subsetsView.el.find('input').length).toBe 2
      expect(subsetsView.el).toContainText('epic')

    it 'observes subsets created', ->
      delete subsetsView.subsets.subsets["ss1-version"]
      subsetsView.subsets.subsets["ss3-version"] =
        name: "ss3-version"
        points: 2
        business: 4
        color: 3

      Object.deliverChangeRecords subsetsView.observer
      expect(subsetsView.el.find('input').length).toBe 3
      expect(subsetsView.el).toContainText('version')
