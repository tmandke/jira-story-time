window.JiraStoryTime = window.JiraStoryTime or {}
class window.JiraStoryTime.forcedOrderingView
  constructor: (stories) ->
    possiblePoints = [1,2,3,5,8,13,21,window.JiraStoryTime.Story.NoPoints]
    $("#story_board").append window.JiraStoryTime.Templates['forcedOrderingView.html']
    storystack = $(".story-stack")
    storystack2 = $("#drop-zone")
    $.map stories, (s) ->
      unless s.isCurrent
        view = new window.JiraStoryTime.StoryView(s, storystack)
        s.initialize()

    possiblePoints.forEach (p) ->
      storystack.append(window.JiraStoryTime.Templates['pointCard.html'])
      $(storystack.children()[storystack.children().length - 1]).html("\u25BC\u25BC\u25BC  " + p  + "  \u25BC\u25BC\u25BC")
      $(storystack.children()[storystack.children().length - 1]).attr('id', 'story-point-' + p)
      $(storystack.children()[storystack.children().length - 1]).attr('data-story-points', p)

    $('#story_board_epics').prepend('<div id="storiesCount" class="story-points" style="display: block">' + $('.story').length + '</div>')
    $('.story').each (i, dom) =>
      dom.addEventListener("dragstart", @dragstart)
      dom.addEventListener("dragover", @dragover)
      dom.addEventListener("drop", @drop)
    
    $('#drop-zone')[0].addEventListener "drop", @dropZone
  
  dragstart: (e) ->
    e.dataTransfer.setData "id", $(this).attr("id")

  dragover: (e) ->
    e.preventDefault()

  drop: (e) ->
    id = e.dataTransfer.getData("id")
    $draggingElem = $("#" + id)
    indexDrag = $draggingElem.index()
    indexThis = $(this).index()
    if indexDrag < indexThis
      $draggingElem.insertAfter(this)
    else if indexDrag > indexThis
      $draggingElem.insertBefore(this)
    
    $('#storiesCount').html($('.story-stack').find('.story').length)

  dropZone: (e) ->
    id = e.dataTransfer.getData("id")
    placed = false
    $(this).children().each (i, div) ->
      if $(div).offset().top > e.y
        $("#" + id).insertBefore div
        placed = true
        return false

    $(this).append($("#" + id)) unless placed
    $('#storiesCount').html($('.story-stack').find('.story').length)
