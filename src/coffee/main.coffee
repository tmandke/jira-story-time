window.JiraStoryTime.Templates.fetchAll ->
  isStoryTime = ->
    window.JiraStoryTime.Util.deparam(location.href.split("?")[1])["story_time"] is "true"
    
  setStoryTime = (st) ->
    params = window.JiraStoryTime.Util.deparam(location.href.split("?")[1])
    params["story_time"] = st
    newUrl = location.href.split("?")[0] + "?" + $.param(params)
    history.pushState null, null, newUrl
    
  renderStoryTime = ->
    possiblePoints = [0,1,2,3,5,8,13,21,window.JiraStoryTime.Story.NoPoints]
    
    setStoryTime true  unless isStoryTime()
    $.when(window.JiraStoryTime.Stories.fetchStories()).done ->
      $(document.body).append window.JiraStoryTime.Templates.board
      $(".overlay").focus()
      window.JiraStoryTime.Stories.addEpic "None"
      if window.JiraStoryTime.isForcedOrdered
        $("#story_board").append window.JiraStoryTime.Templates.forcedOrderedBoard

        storystack = $(".story-stack")
        $.map window.JiraStoryTime.Stories.backlog_stories, (s) ->
          s.initialize storystack
        window.JiraStoryTime.forcedOrderingController.setup()

      else
        possiblePoints.forEach (points) ->
          $("#story_board").append window.JiraStoryTime.Templates.boardRow
          $("#story_board")[0].lastChild.setAttribute "data-story-points", points
          $("#story_board")[0].lastChild.setAttribute "id", "story-points-" + points
          $($("#story_board")[0].lastChild).find(".story_board_row_points").html points

        undefinedCol = $($("#story_board")[0].lastChild)
        $.map window.JiraStoryTime.Stories.backlog_stories, (s) ->
          s.initialize undefinedCol

        window.JiraStoryTime.DragController.setup()

      
      # esc
      $(".overlay").keyup (e) ->
        if e.keyCode is 27
          window.JiraStoryTime.Util.abortAllXHR()
          setStoryTime false
          $.map window.JiraStoryTime.Stories.backlog_stories, (s) ->
            s.close()

          $(".overlay").off()
          $(".overlay").find("*").addBack().off()
          $(".overlay")[0].remove()
          window.JiraStoryTime.Stories.epics = []
          
    
    
  $("#ghx-modes").append window.JiraStoryTime.Templates.storytoggle

  $("#story-toggle").on "click", renderStoryTime
  renderStoryTime()  if isStoryTime()
