describe 'Models.Story', ->
  story     = null
  appState  = null
  basicData = null
  fullData  = null
  beforeEach ->
    basicData = getJSONFixture('stories/basic_SYMAN-10.json')
    fullData  = getJSONFixture('stories/full_SYMAN-10.json')
    jasmine.Ajax.install()
    spyOn(JiraStoryTime.Models.Story.prototype, 'updateState').and.callThrough()
    spyOn(JiraStoryTime.Models.Story.prototype, 'getFullStory').and.callThrough()
    appState  = new JiraStoryTime.Models.ApplicationState()
    story     = new JiraStoryTime.Models.Story basicData, 1, appState

  afterEach ->
    story.deconstruct()
    jasmine.Ajax.uninstall()

  describe '.constructor', ->
    it 'sets id', ->
      expect(story.id).toBe basicData.id

    it 'calls getFullStory', ->
      expect(JiraStoryTime.Models.Story.prototype.getFullStory).toHaveBeenCalled()

    it 'calls updateState', ->
      expect(JiraStoryTime.Models.Story.prototype.updateState).toHaveBeenCalled()
      expect(story.serverSync).toBe appState.serverSync
      #assuming auto update is enabled by default
      expect(story.autoUpdateInterval).toBeDefined()

    it 'application state is observed', ->
      JiraStoryTime.Models.Story.prototype.updateState.calls.reset()
      appState.serverSync = !appState.serverSync
      Object.deliverChangeRecords story.observer
      expect(JiraStoryTime.Models.Story.prototype.updateState).toHaveBeenCalled()
      expect(story.serverSync).toBe appState.serverSync

  describe '#updateIsCurrent', ->
    it 'sets story to current if contained in list', ->
      story.updateIsCurrent [story.id]
      expect(story.isCurrent).toBe true

    it 'sets story to not current if not contained in list', ->
      story.updateIsCurrent [story.id]
      expect(story.isCurrent).toBe true
      story.updateIsCurrent []
      expect(story.isCurrent).toBe false

  describe '#toggelOpen', ->
    it 'toggels the isOpen flag', ->
      newIsOpen = !story.isOpen
      story.toggelOpen()
      expect(story.isOpen).toBe newIsOpen

  describe '#updateState', ->
    it 'updates serverSync flag and clears auto update interval', ->
      # assumes both states are true by default
      appState.serverSync = !appState.serverSync
      appState.autoUpdate = !appState.autoUpdate
      Object.deliverChangeRecords story.observer
      expect(story.serverSync).toBe appState.serverSync
      expect(story.autoUpdateInterval).toBeUndefined()

    it 'creates a autoUpdateInterval', ->
      # assumes auto update state is true by default
      appState.autoUpdate = !appState.autoUpdate
      Object.deliverChangeRecords story.observer
      appState.autoUpdate = !appState.autoUpdate
      Object.deliverChangeRecords story.observer
      expect(story.autoUpdateInterval).toBeDefined()

  describe '#getFullStory', ->
    it 'calls #setMoreData when response is recieved', ->
      spyOn story, 'setMoreData'
      story.getFullStory()
      request = jasmine.Ajax.requests.mostRecent()
      expect(request.url).toContain "details.json"
      expect(request.url).toContain "issueIdOrKey=#{story.id}"
      expect(request.url).toContain "rapidViewId=#{story.rapidView}"
      expect(request.method).toBe 'GET'
      request.response({status: 200, responseText: "{}"})
      expect(story.setMoreData).toHaveBeenCalled()

  describe '#setMoreData', ->
    it 'sets all fields properly', ->
      story.setMoreData fullData
      expect(story.key).toBe 'SYMAN-10'
      expect(story.summary).toBe 'g'
      expect(story.points).toBe 8
      expect(story.business).toBe 3
      expect(story.description).toBe 'SYMAN-10 test desc'
      expect(story.epic).toBe 'Epic 2'


  describe '#deconstruct', ->
    it 'clears autoupdate interval and calls unboserve all', ->
      expect(story.autoUpdateInterval).toBeDefined()
      spyOn(story, 'unobserveAll').and.callThrough()
      story.deconstruct()
      expect(story.unobserveAll).toHaveBeenCalled()
      expect(story.autoUpdateInterval).toBeUndefined()

