class window.JiraStoryTime.Models.ApplicationState
  devMode: false

  constructor: ->
    [
      JiraStoryTime.Utils.Params.boolParam('autoUpdate', true),
      JiraStoryTime.Utils.Params.boolParam('serverSync', true),
      JiraStoryTime.Utils.Params.boolParam('storyTimeActive', false),
      JiraStoryTime.Utils.Params.radioParam('pointsType', 'StroyPoints', ['StroyPoints', 'BusinessValue']),
      JiraStoryTime.Utils.Params.radioParam('view', 'Regular', ['Regular', 'Forced'])
    ].forEach (param) =>
      Object.defineProperty(@, param.paramName,
        get: param.getParam
        set: (val) ->
          Object.getNotifier(this).notify
            type: 'update',
            name: param.paramName,
            oldValue: param.getParam
          param.setParam val
      )
