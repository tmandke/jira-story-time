describe 'Views.ApplicationMenu', ->
  describe '.constructor', ->
    appState = null
    menuEl = null
    waitsFor = (condition, callback, timeout, iterations) ->
      if condition() || iterations == 1
        callback()
      else
        setTimeout(waitsFor, timeout, condition, callback, timeout, iterations - 1)

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
          param.possibleValues.forEach (val) ->
            cleanVal = val.replace new RegExp(' ','g') , ""
            expect(menuEl).toContainElement(".radio-menu-item input#JST-#{param.paramName}-#{cleanVal}")


    it 'changes appState when other value is clicked', (done)->
      paramsCheckCompleted = 0
      appState.queryParams.forEach (param) ->
        if param.type is 'bool'
          newVal = !param.getParam()
          menuEl.find(".bool-menu-item label[for=JST-#{param.paramName}]").click()
        else
          currVal = param.getParam()
          newVal = param.possibleValues.filter( (v) ->
            not(v is currVal)
          )[0]
          cleanVal = newVal.replace new RegExp(' ','g') , ""
          menuEl.find(".radio-menu-item label[for=JST-#{param.paramName}-#{cleanVal}]").click()

        waitsFor((=>
            param.getParam() == newVal),
          (=>
            expect(param.getParam()).toBe(newVal)
            paramsCheckCompleted++
            ),
          10, 1
          )

      waitsFor((=>
          paramsCheckCompleted == appState.queryParams.length),
        done, 10, 10
        )

  describe '#deconstruct', ->
    it 'has method to deconstruct', ->
      expect(JiraStoryTime.Views.ApplicationMenu.prototype.deconstruct).toBeDefined()
