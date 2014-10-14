describe 'Params', ->
  describe 'GenralParam', ->
    param = null
    beforeEach ->
      param = new JiraStoryTime.Utils.Params.GenralParam 'test', 'string', '1', ['1', '123']

    describe '#parseValue ', ->
      it 'returns value passed in', ->
        expect(param.parseValue('123')).toBe '123'

    describe '#validateValue', ->
      it 'returns the same value if it is valid', ->
        expect(param.validateValue('1')).toBe '1'

      it 'throws exception if value is not possible', ->
        expect(->
          param.validateValue('1111')
        ).toThrow()

    describe '#getParam', ->
      it 'returns urls params value', ->
        spyOn(JiraStoryTime.Utils.Params, 'url').and.returnValue "test?JST_test=123"
        expect(param.getParam()).toBe '123'

      it 'returns default if non possible value picked', ->
        spyOn(JiraStoryTime.Utils.Params, 'url').and.returnValue "test?JST_test=111"
        expect(param.getParam()).toBe '1'

      it 'returns default if param does not exist', ->
        spyOn(JiraStoryTime.Utils.Params, 'url').and.returnValue "test?JST_test2=123"
        expect(param.getParam()).toBe '1'

    describe '#setParam', ->
      it 'throws exception if infalid value is set', ->
        expect(->
          param.setParam('1111')
        ).toThrow()

      it 'should set url to', ->
        spyOn(window.JiraStoryTime.Utils.Params, 'setParams')
        spyOn(JiraStoryTime.Utils.Params, 'url').and.returnValue "test?JST_test=1"
        param.setParam('123')
        expect(window.JiraStoryTime.Utils.Params.setParams).toHaveBeenCalledWith(JST_test:'123')

  describe 'BoolParam', ->
    param = null
    beforeEach ->
      param = new JiraStoryTime.Utils.Params.BoolParam 'test', true

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
      param = JiraStoryTime.Utils.Params.boolParam('test', true)
      expect(param.paramName).toBe 'test'
      expect(param.type).toBe 'bool'
      expect(param.default).toBe true
      expect(param.possibleValues).toEqual [true, false]
      expect(param.parseValue('true')).toBe true


  describe '.radioParam', ->
    it 'return a GenralParam object or type radio', ->
      param = JiraStoryTime.Utils.Params.radioParam('test', '123', ['123'])
      expect(param.paramName).toBe 'test'
      expect(param.type).toBe 'radio'
      expect(param.default).toBe '123'
      expect(param.possibleValues).toEqual ['123']

  describe '.genralParam', ->
    it 'return a GenralParam object', ->
      param = JiraStoryTime.Utils.Params.genralParam('test', 'string', '123', ['123'])
      expect(param.paramName).toBe 'test'
      expect(param.type).toBe 'string'
      expect(param.default).toBe '123'
      expect(param.possibleValues).toEqual ['123']

  describe '.getCurrentParams', ->
    it 'return a hash of params', ->
      spyOn(JiraStoryTime.Utils.Params, 'url').and.returnValue "test?test=1&test2=true"
      params = JiraStoryTime.Utils.Params.getCurrentParams()
      expect(params.test).toBe '1'
      expect(params.test2).toBe 'true'

  describe '.deparam', ->
    it 'return a hash of params', ->
      params = JiraStoryTime.Utils.Params.deparam("test=1&test2=true")
      expect(params.test).toBe '1'
      expect(params.test2).toBe 'true'
