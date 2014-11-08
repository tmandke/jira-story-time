beforeEach ->
  stubQueryParams = []
  spyOn(window.JiraStoryTime.Utils.Params, 'getCurrentParams').and.returnValue stubQueryParams
  spyOn(window.JiraStoryTime.Utils.Params, 'setParams').and.callFake (params) ->
    stubQueryParams = params
