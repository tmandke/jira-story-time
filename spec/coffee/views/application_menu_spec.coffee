describe 'ApplicationMenu', ->
  describe '.constructor', ->
    appState = null
    menuEl = null
    beforeEach ->
      appState = new JiraStoryTime.Models.ApplicationState()
      appState.storyTimeActive = true
      menuEl = new JiraStoryTime.Views.ApplicationMenu(appState).el
      setFixtures menuEl

    it 'add all query param items', ->
      appState.queryParams.forEach (param) ->
        if param.type is 'bool'
          expect(menuEl).toContainElement(".bool-menu-item input#JST-#{param.paramName}")
        else
          param.possibleValues.forEach (val) =>
            cleanVal = val.replace new RegExp(' ','g') , ""
            expect(menuEl).toContainElement(".radio-menu-item input#JST-#{param.paramName}-#{cleanVal}")


    it 'changes appState when other value is clicked', ->
      appState.queryParams.forEach (param) ->
        if param.type is 'bool'
          newVal = !param.getParam()
          menuEl.find(".bool-menu-item label[for=JST-#{param.paramName}]").click()
          expect(param.getParam()).toBe newVal
        else
          currVal = param.getParam()
          newVal = param.possibleValues.filter( (v) ->
            not(v is currVal)
          )[0]
          cleanVal = newVal.replace new RegExp(' ','g') , ""
          menuEl.find(".radio-menu-item label[for=JST-#{param.paramName}-#{cleanVal}]").click()
          expect(param.getParam()).toBe newVal
