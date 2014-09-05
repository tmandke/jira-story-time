window.JiraStoryTime = window.JiraStoryTime or {}
window.JiraStoryTime.Util = class Util
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


  @xhrPool: []
  @abortAllXHR: =>
    @xhrPool.forEach (jqXHR) ->
      jqXHR.abort()

    @xhrPool.length = 0

  @saveStroyValues: ->
    points = '--'
    $('#drop-zone').children().each (i, div) ->
      if ($(div).attr('data-story-points')?)
        points = $(div).attr('data-story-points')
      else
        window.JiraStoryTime.Stories.backlog_stories[$(div).find('.story-key').html()].setPoints(points)

window.JiraStoryTime.isForcedOrdered = window.JiraStoryTime.Util.deparam(location.href.split("?")[1])["forced_ordered"] is "true"

$.ajaxSetup
  beforeSend: (jqXHR) ->
    Util.xhrPool.push jqXHR

  complete: (jqXHR) ->
    index = Util.xhrPool.indexOf(jqXHR)
    Util.xhrPool.splice index, 1  if index > -1

