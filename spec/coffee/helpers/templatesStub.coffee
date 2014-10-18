beforeEach ->
  window.JiraStoryTime.Utils.Templates.templateUrl = (fileName) ->
    "/extension/templates/#{fileName}"
