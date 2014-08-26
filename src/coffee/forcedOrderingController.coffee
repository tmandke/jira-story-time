window.JiraStoryTime = window.JiraStoryTime or {}
window.JiraStoryTime.forcedOrderingController =
  setup: ->
    $('.story').each (i, dom) ->
      dom.addEventListener("dragstart", (e) ->
        e.dataTransfer.setData "id", $(this).attr("id") )
      dom.addEventListener("dragover", (e) ->
        e.preventDefault())
      dom.addEventListener "drop", (e) ->
        id = e.dataTransfer.getData("id")
        $draggingElem = $("#" + id)
        indexDrag = $draggingElem.index()
        indexThis = $(this).index()
        if indexDrag < indexThis
          $draggingElem.insertAfter this
        else if indexDrag > indexThis
          $draggingElem.insertBefore this  
    
    $('#drop-zone')[0].addEventListener "drop", (e) ->
      id = e.dataTransfer.getData("id")
      placed = false
      $(this).children().each (i, div) ->
        if $(div).offset().top > e.y
          $("#" + id).insertBefore div
          placed = true
          return false

      $(this).append($("#" + id)) unless placed
