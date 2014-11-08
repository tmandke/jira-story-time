window.JiraStoryTime.Util = class Util
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

$.ajaxSetup
  beforeSend: (jqXHR) ->
    Util.xhrPool.push jqXHR

  complete: (jqXHR) ->
    index = Util.xhrPool.indexOf(jqXHR)
    Util.xhrPool.splice index, 1  if index > -1

