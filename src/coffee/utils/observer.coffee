class window.JiraStoryTime.Utils.Observer
  observe: (objToObserve) =>
    @observedObjects ||= []
    @observedObjects.push objToObserve
    @baseObject(objToObserve).observe(objToObserve, @observer)

  baseObject: (obj) ->
    if obj instanceof Array then Array else Object

  observer: (changes) =>
    changes.forEach @onObservedChange

  #implement this method
  onObservedChange: (change) ->
    throw new Error("onObservedChange has not been implemented")


  unobserve: (obj)=>
    @observedObjects ||= []
    if idx = @observedObjects.indexOf(obj) > -1
      Object.unobserve obj, @observer
      @observedObjects.splice idx, 1

  unobserveAll: =>
    @observedObjects ||= []
    @observedObjects.forEach (obj) =>
      @baseObject(obj).unobserve obj, @observer
    @observedObjects = []
