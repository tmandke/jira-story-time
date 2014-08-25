window.JiraStoryTime.Templates.fetchAll ->
  isStoryTime = ->
    window.JiraStoryTime.Util.deparam(location.href.split("?")[1])["story_time"] is "true"
    
  setStoryTime = (st) ->
    params = window.JiraStoryTime.Util.deparam(location.href.split("?")[1])
    params["story_time"] = st
    newUrl = location.href.split("?")[0] + "?" + $.param(params)
    history.pushState null, null, newUrl
    return
    
  renderStoryTime = ->
    setStoryTime true  unless isStoryTime()
    $.when(window.JiraStoryTime.Stories.fetchStories()).done ->
      $(document.body).append window.JiraStoryTime.Templates.board
      $(".overlay").focus()
      window.JiraStoryTime.Stories.addEpic "None"
      [
        0
        1
        2
        3
        5
        8
        13
        21
        window.JiraStoryTime.Story.NoPoints
      ].forEach (points) ->
        $("#story_board").append window.JiraStoryTime.Templates.boardRow
        $("#story_board")[0].lastChild.setAttribute "data-story-points", points
        $("#story_board")[0].lastChild.setAttribute "id", "story-points-" + points
        $($("#story_board")[0].lastChild).find(".story_board_row_points").html points
        return

      undefinedCol = $($("#story_board")[0].lastChild)
      $.map window.JiraStoryTime.Stories.backlog_stories, (s) ->
        s.initialize undefinedCol
        return

      window.JiraStoryTime.DragController.setup()
      $(".overlay").keyup (e) ->
        if e.keyCode is 27
          window.JiraStoryTime.Util.abortAllXHR()
          setStoryTime false
          $.map window.JiraStoryTime.Stories.backlog_stories, (s) ->
            s.close()
            return

          $(".overlay").off()
          $(".overlay").find("*").addBack().off()
          $(".overlay")[0].remove()
          window.JiraStoryTime.Stories.epics = []
        return

      return

    return
    
  $("#ghx-modes").append window.JiraStoryTime.Templates.storytoggle

  # esc
  $("#story-toggle").on "click", renderStoryTime
  renderStoryTime()  if isStoryTime()
  return
