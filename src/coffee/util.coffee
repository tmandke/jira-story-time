window.JiraStoryTime = window.JiraStoryTime or {}
window.JiraStoryTime.Util =
  deparam: (query) ->
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

  xhrPool: []
  abortAllXHR: ->
    window.JiraStoryTime.Util.xhrPool.forEach (jqXHR) ->
      jqXHR.abort()
      return

    window.JiraStoryTime.Util.xhrPool.length = 0
    return

$.ajaxSetup
  beforeSend: (jqXHR) ->
    window.JiraStoryTime.Util.xhrPool.push jqXHR
    return

  complete: (jqXHR) ->
    index = window.JiraStoryTime.Util.xhrPool.indexOf(jqXHR)
    window.JiraStoryTime.Util.xhrPool.splice index, 1  if index > -1
    return
