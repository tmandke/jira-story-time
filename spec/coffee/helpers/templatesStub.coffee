beforeEach ->
  spyOn(JiraStoryTime.Utils.Templates, 'templateUrl').and.callFake (fileName) ->
    "/extension/templates/#{fileName}"
