class window.JiraStoryTime.Utils.Params
  @GenralParam: class GenralParam
    constructor: (@paramName, @humanName, @type, @default, @possibleValues, @visible) ->
      unless @visible?
        @visible = true

    getParam: =>
      params = window.JiraStoryTime.Utils.Params.getCurrentParams()
      val = try
        @parseValue(params["JST_#{@paramName}"])
      catch err
        @default

      if @isValueValid val then val else @default

    parseValue: (val) ->
      val

    isValueValid: (val) =>
      @possibleValues.indexOf(val) > -1

    setParam: (val) =>
      if @isValueValid(val)
        params = window.JiraStoryTime.Utils.Params.getCurrentParams()
        params["JST_#{@paramName}"] = val
        window.JiraStoryTime.Utils.Params.setParams(params)
      else
        throw("Invalid Value '#{val}' for param #{@paramName}")

  @BoolParam: class BoolParam extends GenralParam
    constructor: (@paramName, @humanName, @default, @visible) ->
      super @paramName, @humanName, 'bool', @default, [true, false], @visible

    parseValue: (val) ->
      $.parseJSON(val)

  @boolParam: (paramName, humanName, defaultVal, visible) ->
    new BoolParam paramName, humanName, defaultVal, visible

  @radioParam: (paramName, humanName, defaultVal, possibleValues, visible) ->
    @genralParam paramName, humanName, 'radio', defaultVal, possibleValues, visible

  @genralParam: (paramName, humanName, type, defaultVal, possibleValues, visible) ->
    new GenralParam(paramName, humanName, type, defaultVal, possibleValues, visible)

  @getCurrentParams: ->
    @currParams ||= window.JiraStoryTime.Utils.Params.deparam(@url().split("?")[1])

  @deparam: (query) ->
    query ||= ""
    pairs = undefined
    i = undefined
    keyValuePair = undefined
    key = undefined
    value = undefined
    map = {}

    # remove leading question mark if its there
    query = query.slice(1)  if query.slice(0, 1) is "?"
    if query isnt ""
      pairs = query.split("&")
      i = 0
      while i < pairs.length
        keyValuePair = pairs[i].split("=")
        key = decodeURIComponent(keyValuePair[0])
        value = (if (keyValuePair.length > 1) then decodeURIComponent(keyValuePair[1]) else undefined)
        map[key] = if typeof value is 'string' then value.replace("+"," ") else value
        i += 1
    map

  @setParams: (params)->
    newUrl = location.href.split("?")[0] + "?" + $.param(params)
    history.pushState null, null, newUrl


  @url: ->
    location.href
