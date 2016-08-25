JiraStoryTime.Models.Errors = []
class JiraStoryTime.Models.Error
  constructor: (@message, @jqXHR) ->

  possibleSolution: =>
    if @jqXHR.status == 0
      "Seems like the request was aborted. There is not much that can be done with this information."
    else if (@jqXHR.responseText.search(/NullPointerException(.|\n)*EpicServiceImpl\.getEpicStatusValue/) > -1)
      "The Epic Status for some Epics is Empty. This happens when a 'Story' is converted to an 'Epic'. Follow the workaround #{@_link "https://jira.atlassian.com/browse/JSW-12624", "here"}."
    else if (@jqXHR.responseText.search(/Field '.*' cannot be set\. It is not on the appropriate screen, or unknown\./) > -1)
      @_link "https://confluence.atlassian.com/adminjiracloud/defining-a-screen-776636475.html#Definingascreen-Configuringascreen'stabsandfields", "Add the field to Projects Screen."
    else
      "Please do check if there is already a issue #{@_link "https://github.com/tmandke/jira-story-time/issues", "here"} " +
        "for this error and if there is none create one."

  _link: (href, text) ->
    "<a href=\"#{href}\" target=\"_blank\">#{text}&rarr;</a>"

  responseStatus: =>
    @jqXHR.status

  responseText: =>
    @jqXHR.responseText
