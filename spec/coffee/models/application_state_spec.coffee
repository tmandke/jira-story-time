describe 'Models.ApplicationState', ->
  describe '.constructor', ->
    state = null
    params = ['autoUpdate', 'serverSync', 'storyTimeActive', 'pointsType', 'subsets']
    beforeEach ->
      state = new JiraStoryTime.Models.ApplicationState()

    it 'creates getters and setters for all queryParams', ->
      params.forEach (param) ->
        expect(state[param]).toBeDefined("Param '#{param}' is not defined")

    describe 'queryProperties', ->
      observer = null
      observedChanges = null

      beforeEach ->
        observer = new JiraStoryTime.Utils.Observer()
        observedChanges = []
        spyOn(observer, 'onObservedChange').and.callFake((change) ->
          observedChanges.push change.name
        )
        observer.observe(state)

      afterEach ->
        observer.unobserveAll()

      it 'are all observable', ->
        state.autoUpdate = false
        state.serverSync = false
        state.storyTimeActive = true
        state.pointsType = 'Business Value'
        state.subsets = 'epic'
        Object.deliverChangeRecords observer.observer

        expect(observedChanges).toEqual(params)

      it 'throw validation exception when invalid value is set', ->
        expect(->
          state.autoUpdate = 1
        ).toThrow()
        Object.deliverChangeRecords observer.observer
        expect(observedChanges).toEqual([])

      it 'no event to be if the same value is set', ->
        state.autoUpdate = true
        Object.deliverChangeRecords observer.observer
        expect(observedChanges).toEqual([])
