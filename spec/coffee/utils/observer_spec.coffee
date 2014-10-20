describe 'Utils.Observer', ->
  describe '#observe', ->
    it 'should setup object observer and add object to observedObject list', ->
      obj = new window.JiraStoryTime.Utils.Observer
      obj2 = {test: 1}
      spyOn(Object, 'observe')
      obj.observe(obj)
      obj.observe(obj2)
      expect(Object.observe).toHaveBeenCalledWith(obj, obj.observer)
      expect(Object.observe).toHaveBeenCalledWith(obj2, obj.observer)
      expect(obj.observedObjects.length).toBe 2
      expect(obj.observedObjects[0]).toBe obj
      expect(obj.observedObjects[1]).toBe obj2

  describe '#observer', ->
    it 'should call all observed', ->
      obj = new window.JiraStoryTime.Utils.Observer
      spyOn(obj, 'onObservedChange')
      changeEvent1 = {
        object: obj
        myChange: 123
      }
      changeEvent2 = {
        object: {qwe:1}
        myChange: 123
      }
      changes = [changeEvent1, changeEvent2]
      obj.observer(changes)
      expect(obj.onObservedChange).toHaveBeenCalledWith(changeEvent1, 0, changes)
      expect(obj.onObservedChange).toHaveBeenCalledWith(changeEvent2, 1, changes)

  describe '#onObservedChange', ->
    it 'throws unimplimented', ->
      obj = new window.JiraStoryTime.Utils.Observer
      expect(obj.onObservedChange).toThrow("onObservedChange has not been implemented")

  describe '#unobserveAll', ->
    it 'unobserves all objects', ->
      obj = new window.JiraStoryTime.Utils.Observer
      obj2 = {test: 1}
      obj.observedObjects = [obj, obj2]
      spyOn(Object, 'unobserve')
      obj.unobserveAll()
      expect(Object.unobserve).toHaveBeenCalledWith(obj, obj.observer)
      expect(Object.unobserve).toHaveBeenCalledWith(obj2, obj.observer)
      expect(obj.observedObjects.length).toBe 0

