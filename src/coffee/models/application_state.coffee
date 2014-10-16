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
          if param.isValueValid val
            oldVal = param.getParam()
            unless val is oldVal
              Object.getNotifier(this).notify
                type: 'update',
                name: param.paramName,
                oldValue: oldVal
              param.setParam val
          else
            # using setParam since I dont want to rewite the throw message
            param.setParam val
      )
