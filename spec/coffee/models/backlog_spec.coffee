describe 'Models.Backlog', ->
  backlog   = null
  appState  = null
  fixtures  = {}
  beforeEach ->
    fixtures.backlog = getJSONFixture('backlogs/backlog.json')
    jasmine.Ajax.install()
    spyOn(JiraStoryTime.Models.Backlog.prototype, 'updateState').and.callThrough()
    spyOn(JiraStoryTime.Models.Backlog.prototype, 'updateBacklog').and.callThrough()
    appState  = new JiraStoryTime.Models.ApplicationState()
    backlog   = new JiraStoryTime.Models.Backlog 1, appState

  afterEach ->
    backlog.deconstruct()
    jasmine.Ajax.uninstall()

  describe '.constructor', ->
    it 'observes application state', ->
      expect(backlog.autoUpdateInterval).toBeDefined()
      JiraStoryTime.Models.Backlog.prototype.updateState.calls.reset()
      appState.autoUpdate = false
      Object.deliverChangeRecords backlog.observer
      expect(JiraStoryTime.Models.Backlog.prototype.updateState).toHaveBeenCalled()
      expect(backlog.autoUpdateInterval).toBeUndefined()

    it 'observes all stories', ->
      backlog.parseResponse(fixtures.backlog)
      expect(backlog.stories[fixtures.backlog.issues[0].id]).toBeDefined()
      expect(backlog.issues[fixtures.backlog.issues[0].id]).toBeDefined()
      backlog.issues[fixtures.backlog.issues[0].id].type = 'Task'
      Object.deliverChangeRecords backlog.observer
      expect(backlog.stories[fixtures.backlog.issues[0].id]).toBeUndefined()
      expect(backlog.issues[fixtures.backlog.issues[0].id]).toBeDefined()
      backlog.issues[fixtures.backlog.issues[0].id].type = 'Task2'
      Object.deliverChangeRecords backlog.observer
      expect(backlog.stories[fixtures.backlog.issues[0].id]).toBeUndefined()
      expect(backlog.issues[fixtures.backlog.issues[0].id]).toBeDefined()
      backlog.issues[fixtures.backlog.issues[0].id].type = 'Story'
      Object.deliverChangeRecords backlog.observer
      expect(backlog.stories[fixtures.backlog.issues[0].id]).toBeDefined()
      expect(backlog.issues[fixtures.backlog.issues[0].id]).toBeDefined()

    it 'sets up autoUpdateInterval', ->
      expect(JiraStoryTime.Models.Backlog.prototype.updateState).toHaveBeenCalled()
      expect(backlog.autoUpdateInterval).toBeDefined()

    it 'updates backlog', ->
      expect(JiraStoryTime.Models.Backlog.prototype.updateBacklog).toHaveBeenCalled()

  describe '#updateState', ->
    it 'deletes autoUpdateInterval when autoUpdateInterval is set to false', ->
      expect(backlog.autoUpdateInterval).toBeDefined()
      appState.autoUpdate = false
      Object.deliverChangeRecords backlog.observer
      expect(backlog.autoUpdateInterval).toBeUndefined()

    it 'creates autoUpdateInterval when autoUpdateInterval is set to to', ->
      appState.autoUpdate = false
      Object.deliverChangeRecords backlog.observer
      expect(backlog.autoUpdateInterval).toBeUndefined()
      appState.autoUpdate = true
      Object.deliverChangeRecords backlog.observer
      expect(backlog.autoUpdateInterval).toBeDefined()

  describe '#updateBacklog', ->
    it 'calls #parseResponse when response is recieved', ->
      spyOn backlog, 'parseResponse'
      backlog.updateBacklog()
      request = jasmine.Ajax.requests.mostRecent()
      expect(request.url).toContain "data.json"
      expect(request.url).toContain "rapidViewId=#{backlog.rapidView}"
      expect(request.method).toBe 'GET'
      request.response({status: 200, responseText: "{}"})
      expect(backlog.parseResponse).toHaveBeenCalled()

  describe '#parseResponse', ->
    it 'generates a hash of stories', ->
      backlog.parseResponse(fixtures.backlog)
      ids = $(fixtures.backlog.issues).map((idx, issue) ->
        issue.id.toString()
      ).toArray().sort()

      expect(Object.keys(backlog.stories)).toEqual(ids)

    it 'removes stories that are missing', ->
      backlog.parseResponse(fixtures.backlog)
      ids = $(fixtures.backlog.issues).map((idx, issue) ->
        issue.id.toString()
      ).toArray().sort()
      expect(Object.keys(backlog.stories)).toEqual(ids)
      removed = fixtures.backlog.issues.splice(5,1)
      ids.splice(ids.indexOf(removed[0].id.toString()),1)
      backlog.parseResponse(fixtures.backlog)
      expect(Object.keys(backlog.stories)).toEqual(ids)

  describe '#deconstruct', ->
    it 'clears autoupdate interval, deconstructs all stories and calls unboserve all', ->
      expect(backlog.autoUpdateInterval).toBeDefined()
      spyOn(backlog, 'unobserveAll').and.callThrough()
      backlog.deconstruct()
      expect(backlog.unobserveAll).toHaveBeenCalled()
      expect(backlog.autoUpdateInterval).toBeUndefined()
      expect(Object.keys backlog.stories).toEqual([])
