stubQueryParams = []
window.resetQueryParams = ->
  stubQueryParams = []

window.JiraStoryTime.Utils.Params.getCurrentParams = ->
  stubQueryParams

window.JiraStoryTime.Utils.Params.setParams = (params) ->
  stubQueryParams = params
