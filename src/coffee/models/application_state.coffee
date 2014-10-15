class window.JiraStoryTime.Models.ApplicationState extends window.JiraStoryTime.Utils.Observer
  devMode: false

  constructor: ->
    [
      JiraStoryTime.Utils.Params.boolParam('AutoUpdate', true),
      JiraStoryTime.Utils.Params.boolParam('ServerSync', true),
      JiraStoryTime.Utils.Params.boolParam('StoryTimeActive', false),
      JiraStoryTime.Utils.Params.radioParam('PointsType', 'StroyPoints', ['StroyPoints', 'BusinessValue']),
      JiraStoryTime.Utils.Params.radioParam('View', 'Regular', ['Regular', 'Forced'])
    ].forEach (param) =>
      @[param.getterName()] = param.getParam
      @[param.setterName()] = param.setParam
