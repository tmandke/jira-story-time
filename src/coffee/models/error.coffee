JiraStoryTime.Models.Errors = []
class JiraStoryTime.Models.Error
  constructor: (@message, @jqXHR) ->

  possibleSolution: =>
    @jqXHR.responseText

  responseStatus: =>
    @jqXHR.status

  responseText: =>
    @jqXHR.responseText
