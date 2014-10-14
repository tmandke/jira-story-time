class window.JiraStoryTime.Utils.Observer
  observedObjects: []

  observe: (objToObserve) =>
    @observedObjects << objToObserve
    Object.observe(objToObserve, @observer)

  observer: (changes) =>
    changes.forEach @onObservedChange

  #implement this method
  onObservedChange: (change)=>
    throw "UnImplemented onObservedChange"

  unobserveAll: =>
    @observedObjects.forEach (obj) =>
      Object.unobserve obj, @observer