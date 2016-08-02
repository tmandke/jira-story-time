describe 'Models.Story', ->
  story     = null
  appState  = null
  basicData = null
  beforeEach ->
    basicData = getJSONFixture('stories/BUYA-1.json')
    fields = getJSONFixture('fields.json')
    JiraStoryTime.Models.Story._initFieldIds(fields)
    jasmine.Ajax.install()
    spyOn(JiraStoryTime.Models.Story.prototype, 'updateState').and.callThrough()
    spyOn(JiraStoryTime.Models.Story.prototype, 'setMoreData').and.callThrough()
    appState  = new JiraStoryTime.Models.ApplicationState()
    story     = new JiraStoryTime.Models.Story basicData, 1, appState

  afterEach ->
    story.deconstruct()
    jasmine.Ajax.uninstall()

  describe '.constructor', ->
    it 'sets id', ->
      expect(story.id).toBe basicData.id

    it 'calls setMoreData', ->
      expect(JiraStoryTime.Models.Story.prototype.setMoreData).toHaveBeenCalled()

    it 'calls updateState', ->
      expect(JiraStoryTime.Models.Story.prototype.updateState).toHaveBeenCalled()
      expect(story.serverSync).toBe appState.serverSync

    it 'application state is observed', ->
      JiraStoryTime.Models.Story.prototype.updateState.calls.reset()
      appState.serverSync = !appState.serverSync
      Object.deliverChangeRecords story.observer
      expect(JiraStoryTime.Models.Story.prototype.updateState).toHaveBeenCalled()
      expect(story.serverSync).toBe appState.serverSync

  describe '#isCurrent', ->
    it 'sets story to current if contained in list', ->
      story.sprintState = "active"
      expect(story.isCurrent()).toBe true

    it 'sets story to not current if not contained in list', ->
      story.sprintState = "active"
      expect(story.isCurrent()).toBe true
      story.sprintState = "future"
      expect(story.isCurrent()).toBe false

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

  describe '#setMoreData', ->
    it 'sets all fields properly', ->
      story.setMoreData basicData
      expect(story.key).toBe 'BUYA-1'
      expect(story.summary).toBe 'aaa'
      expect(story.points).toBe 13
      expect(story.business).toBe 3
      expect(story.description).toBe 'BUYA-1 test desc'
      expect(story.epic).toBe 'Epic 2'

  describe '#setProperty', ->
    describe 'server sync is enabled', ->
      it 'sends an update field request and updates property', ->
        story.setProperty('points', 21)
        request = jasmine.Ajax.requests.mostRecent()
        expect(request.url).toContain "update-field.json"
        expect(request.method).toBe 'PUT'
        expect(request.data()).toEqual(
          fieldId: story.constructor._fieldIds.points
          issueIdOrKey: story.id
          newValue: 21
        )
        spyOn console, 'log'
        request.response({status: 200, responseText: '{"test":123}'})
        expect(console.log).toHaveBeenCalledWith({test:123})

    describe 'server sync is disabled', ->
      it 'sends an update field request and updates property', ->
        story.serverSync = false
        spyOn console, 'log'
        story.setProperty('points', 21)
        request = jasmine.Ajax.requests.mostRecent()
        expect(request.url).not.toContain "update-field.json"
        expect(console.log).toHaveBeenCalledWith("#{story.key}: points would have been updated to 21")

  describe '#isVisible', ->
    it 'returns true by default', ->
      expect(story.isVisible()).toBe true

    it 'returns false if one visible_var is false', ->
      story.visible_epic = false
      expect(story.isVisible()).toBe false

    it 'returns true if all visible_vars are true', ->
      story.visible_epic = true
      expect(story.isVisible()).toBe true

  describe '#_parsePoints', ->
    it 'a numeric string returns the number', ->
      expect(story._parsePoints('3')).toBe 3

    it 'a non numeric string returns undefined', ->
      expect(story._parsePoints('aaa')).toBe undefined

    it 'a undefined returns undefined', ->
      expect(story._parsePoints(undefined)).toBe undefined
