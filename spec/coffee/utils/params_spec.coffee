describe 'Utils.Params', ->
  describe 'GenralParam', ->
    param = null
    beforeEach ->
      param = new JiraStoryTime.Utils.Params.GenralParam 'test', 'Test', 'string', '1', ['1', '123']

    describe '#parseValue ', ->
      it 'returns value passed in', ->
        expect(param.parseValue('123')).toBe '123'

    describe '#isValueValid', ->
      it 'returns the same value if it is valid', ->
        expect(param.isValueValid('1')).toBe true

      it 'throws exception if value is not possible', ->
        expect(param.isValueValid('1111')).toBe false

    describe '#getParam', ->
      it 'returns urls params value', ->
        JiraStoryTime.Utils.Params.getCurrentParams.and.returnValue JST_test: '123'
        expect(param.getParam()).toBe '123'

      it 'returns default if non possible value picked', ->
        JiraStoryTime.Utils.Params.getCurrentParams.and.returnValue JST_test: '111'
        expect(param.getParam()).toBe '1'

      it 'returns default if param does not exist', ->
        JiraStoryTime.Utils.Params.getCurrentParams.and.returnValue JST_test2: '123'
        expect(param.getParam()).toBe '1'

    describe '#setParam', ->
      it 'throws exception if infalid value is set', ->
        expect(->
          param.setParam('1111')
        ).toThrow()

      it 'should set url to', ->
        JiraStoryTime.Utils.Params.getCurrentParams.and.returnValue JST_test: '1'
        param.setParam('123')
        expect(window.JiraStoryTime.Utils.Params.setParams).toHaveBeenCalledWith(JST_test:'123')

  describe 'BoolParam', ->
    param = null
    beforeEach ->
      param = new JiraStoryTime.Utils.Params.BoolParam 'test', 'Test', true

    describe '#parseValue ', ->
      it 'returns a parsed value', ->
        expect(param.parseValue('true')).toBe true
        expect(param.parseValue('false')).toBe false

      it 'throws exception if value is not true or false string', ->
        expect(->
          param.parseValue('truew')
        ).toThrow()

  describe '.boolParam', ->
    it 'return a boolParam object or type radio', ->
      param = JiraStoryTime.Utils.Params.boolParam('test', 'Test', true)
      expect(param.paramName).toBe 'test'
      expect(param.type).toBe 'bool'
      expect(param.default).toBe true
      expect(param.possibleValues).toEqual [true, false]
      expect(param.parseValue('true')).toBe true


  describe '.radioParam', ->
    it 'return a GenralParam object or type radio', ->
      param = JiraStoryTime.Utils.Params.radioParam('test', 'Test', '123', ['123'])
      expect(param.paramName).toBe 'test'
      expect(param.type).toBe 'radio'
      expect(param.default).toBe '123'
      expect(param.possibleValues).toEqual ['123']

  describe '.genralParam', ->
    it 'return a GenralParam object', ->
      param = JiraStoryTime.Utils.Params.genralParam('test', 'Test', 'string', '123', ['123'])
      expect(param.paramName).toBe 'test'
      expect(param.type).toBe 'string'
      expect(param.default).toBe '123'
      expect(param.possibleValues).toEqual ['123']

  describe '.deparam', ->
    it 'return a hash of params', ->
      params = JiraStoryTime.Utils.Params.deparam("?test=1&test2=true&test3")
      expect(params.test).toBe '1'
      expect(params.test2).toBe 'true'
      expect(params.test3).toBeUndefined()

  describe '.getCurrentParams', ->
    it 'returns an good hash', ->
      spyOn(JiraStoryTime.Utils.Params, 'url').and.returnValue 'localhost:8888?test=1+12&test2=true&test3'
      JiraStoryTime.Utils.Params.getCurrentParams.and.callThrough()
      params = JiraStoryTime.Utils.Params.getCurrentParams()
      expect(params.test).toBe '1 12'
      expect(params.test2).toBe 'true'
      expect(params.test3).toBeUndefined()

  describe '.url', ->
    it 'returns location.href', ->
      expect(JiraStoryTime.Utils.Params.url()).toBe(location.href)

  describe '.setParams', ->
    url = null
    beforeEach ->
      url = location.href
    afterEach ->
      history.pushState null, null, url

    it 'should set query params', ->
      JiraStoryTime.Utils.Params.setParams.and.callThrough()
      JiraStoryTime.Utils.Params.setParams(
        test1: '1 12'
        test2: true
      )
      expect(location.href.split("?")[1]).toBe('test1=1+12&test2=true')
