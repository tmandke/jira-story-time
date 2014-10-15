describe 'ApplicationState', ->
  describe '.constructor', ->
    it 'creates getters and setters for all queryParams', ->
      state = new JiraStoryTime.Models.ApplicationState()
      ['AutoUpdate', 'ServerSync', 'StoryTimeActive', 'PointsType', 'View'
      ].forEach (param) ->
        expect(state["get#{param}"]).toBeDefined()
        expect(state["set#{param}"]).toBeDefined()


