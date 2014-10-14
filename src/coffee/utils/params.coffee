class window.JiraStoryTime.Utils.Params
  @GenralParam: class GenralParam
    constructor: (@paramName, @type, @default, @possibleValues) ->

    getParam: =>
      params = window.JiraStoryTime.Utils.Params.getCurrentParams()
      try
        @validateValue(@parseValue(params["JST_#{@paramName}"]) || @default)
      catch err
        console.log(err)
        @default

    parseValue: (val) =>
      val

    validateValue: (val) =>
      if @possibleValues.indexOf(val) is -1
        throw("Invalid Value '#{val}' for param #{@paramName}")
      val

    setParam: (val) =>
      @validateValue(val)
      params = window.JiraStoryTime.Utils.Params.getCurrentParams()
      params["JST_#{@paramName}"] = val
      window.JiraStoryTime.Utils.Params.setParams(params)

  @BoolParam: class BoolParam extends GenralParam
    constructor: (@paramName, @default) ->
      super @paramName, 'bool', @default, [true, false]

    parseValue: (val) =>
      $.parseJSON(val)

  @boolParam: (paramName, defaultVal) ->
    new BoolParam paramName, defaultVal

  @radioParam: (paramName, defaultVal, possibleValues) ->
    @genralParam paramName, 'radio', defaultVal, possibleValues

  @genralParam: (paramName, type, defaultVal, possibleValues) ->
    new GenralParam(paramName, type, defaultVal, possibleValues)

  @getCurrentParams: ->
    window.JiraStoryTime.Util.deparam(@url().split("?")[1])

  @deparam: (query) ->
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
        value = (if (keyValuePair.length > 1) then decodeURIComponent(keyValuePair[1]) else `undefined`)
        map[key] = value
        i += 1
    map

  @setParams: (params)->
    newUrl = location.href.split("?")[0] + "?" + $.param(params)
    history.pushState null, null, newUrl


  @url: ->
    location.href
