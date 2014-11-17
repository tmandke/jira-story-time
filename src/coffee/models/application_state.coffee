class window.JiraStoryTime.Models.ApplicationState
  devMode: false

  constructor: ->
    @queryParams = [
      JiraStoryTime.Utils.Params.boolParam('autoUpdate', 'Auto Update', true)
      JiraStoryTime.Utils.Params.boolParam('serverSync', 'Server Sync', true)
      JiraStoryTime.Utils.Params.radioParam('pointsType', 'Points Type', 'Story Points', ['Story Points', 'Business Value'])
      JiraStoryTime.Utils.Params.radioParam('subsets', 'Subsets', 'version', ['version', 'epic'])
      JiraStoryTime.Utils.Params.genralParam('printCards', 'Print Cards', 'click', false, [true, false])
      JiraStoryTime.Utils.Params.genralParam('storyTimeActive', 'Exit', 'click', false, [true, false])
      # JiraStoryTime.Utils.Params.radioParam('view', 'Process View', 'Regular', ['Regular', 'Forced'])
    ]
    @queryParamsHash = {}
    @queryParams.forEach (param) =>
      @queryParamsHash[param.paramName] = param
      if param.type is 'click'
        param.parseValue = (val) ->
          $.parseJSON(val)

      Object.defineProperty(@, param.paramName,
        param: param
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
