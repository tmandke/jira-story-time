describe 'ApplicationState', ->
  describe '.constructor', ->
    it 'creates getters and setters for all queryParams', ->
      state = new JiraStoryTime.Models.ApplicationState()
      ['autoUpdate', 'serverSync', 'storyTimeActive', 'pointsType', 'view'
      ].forEach (param) ->
        expect(state[param]).toBeDefined("Param '#{param}' is not defined")
