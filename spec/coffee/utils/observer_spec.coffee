describe 'Utils.Observer', ->
  describe '#observe', ->
    it 'should setup object observer and add object to observedObject list', ->
      obj = new window.JiraStoryTime.Utils.Observer
      obj2 = {test: 1}
      obj3 = ['a']
      spyOn(Object, 'observe')
      spyOn(Array, 'observe')
      obj.observe(obj)
      obj.observe(obj2)
      obj.observe(obj3)
      expect(Object.observe).toHaveBeenCalledWith(obj, obj.observer)
      expect(Object.observe).toHaveBeenCalledWith(obj2, obj.observer)
      expect(Array.observe).toHaveBeenCalledWith(obj3, obj.observer)
      expect(obj.observedObjects.length).toBe 3
      expect(obj.observedObjects[0]).toBe obj
      expect(obj.observedObjects[1]).toBe obj2
      expect(obj.observedObjects[2]).toBe obj3

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
      expect(obj.onObservedChange).toThrowError("onObservedChange has not been implemented")

  describe '#unobserve', ->
    it 'unobserves obj2', ->
      obj = new window.JiraStoryTime.Utils.Observer
      obj2 = {test: 1}
      obj3 = ['a']
      obj.observedObjects = [obj, obj2, obj3]
      spyOn(Object, 'unobserve')
      obj.unobserve(obj2)
      expect(Object.unobserve).toHaveBeenCalledWith(obj2, obj.observer)
      expect(obj.observedObjects.length).toBe 2

  describe '#unobserveAll', ->
    it 'unobserves all objects', ->
      obj = new window.JiraStoryTime.Utils.Observer
      obj2 = {test: 1}
      obj3 = ['a']
      obj.observedObjects = [obj, obj2, obj3]
      spyOn(Object, 'unobserve')
      spyOn(Array, 'unobserve')
      obj.unobserveAll()
      expect(Object.unobserve).toHaveBeenCalledWith(obj, obj.observer)
      expect(Object.unobserve).toHaveBeenCalledWith(obj2, obj.observer)
      expect(Array.unobserve).toHaveBeenCalledWith(obj3, obj.observer)
      expect(obj.observedObjects.length).toBe 0
