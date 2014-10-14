class window.JiraStoryTime.Utils.Observer
  observedObjects: []

  observe: (objToObserve) =>
    @observedObjects.push objToObserve
    Object.observe(objToObserve, @observer)

  observer: (changes) =>
    changes.forEach @onObservedChange

  #implement this method
  onObservedChange: (change)=>
    throw "onObservedChange has not been implemented"

  unobserveAll: =>
    @observedObjects.forEach (obj) =>
      Object.unobserve obj, @observer