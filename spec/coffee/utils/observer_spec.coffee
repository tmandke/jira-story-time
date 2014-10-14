describe 'Observer', ->
  describe '#observe', ->
    it 'setsUp an observer for all attributes of given object', ->
      obj = new window.JiraStoryTime.Utils.Observer
      obj.attr1 = 1
      obj.attr2 = 2
      spyOn(obj, 'onObservedChange').and.callFake (change)->
        expect(change.object).toBe obj
        expect(change.oldValue).toBe 1
        expect(change.type).toBe 'update'

      obj.observe(obj)

      obj.attr1 = 33

      Object.deliverChangeRecords obj.observer

      expect(obj.onObservedChange).toHaveBeenCalled()

      obj.unobserveAll
