class window.JiraStoryTime.Models.ApplicationState
  devMode: false

  constructor: ->
    @queryParams = [
      JiraStoryTime.Utils.Params.boolParam('storyTimeActive', 'Story Time', false),
      JiraStoryTime.Utils.Params.boolParam('autoUpdate', 'Auto Update', true),
      JiraStoryTime.Utils.Params.boolParam('serverSync', 'Server Sync', true),
      JiraStoryTime.Utils.Params.radioParam('pointsType', 'Points Type', 'Story Points', ['Story Points', 'Business Value']),
      JiraStoryTime.Utils.Params.radioParam('subsets', 'Subsets', 'version', ['version', 'epic']),
      JiraStoryTime.Utils.Params.radioParam('view', 'Process View', 'Regular', ['Regular', 'Forced'])
    ]
    @queryParams.forEach (param) =>
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
