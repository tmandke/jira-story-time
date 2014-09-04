window.JiraStoryTime.Templates.fetchAll ->
  isStoryTime = ->
    window.JiraStoryTime.Util.deparam(location.href.split("?")[1])["story_time"] is "true"
    
  setStoryTime = (st) ->
    params = window.JiraStoryTime.Util.deparam(location.href.split("?")[1])
    params["story_time"] = st
    newUrl = location.href.split("?")[0] + "?" + $.param(params)
    history.pushState null, null, newUrl
    
  renderStoryTime = ->
    window.JiraStoryTime.Stories.resetEpics()
    possiblePoints = [0,1,2,3,5,8,13,21,window.JiraStoryTime.Story.NoPoints]
    
    setStoryTime true  unless isStoryTime()
    $.when(window.JiraStoryTime.Stories.fetchStories()).done ->
      $(document.body).append window.JiraStoryTime.Templates.board
      $(".overlay").focus()
      window.JiraStoryTime.Stories.addEpic "None"
      if window.JiraStoryTime.isForcedOrdered
        $("#story_board").append window.JiraStoryTime.Templates.forcedOrderedBoard

        storystack = $(".story-stack")
        storystack2 = $("#drop-zone")
        $.map window.JiraStoryTime.Stories.backlog_stories, (s) ->
          s.initialize storystack

        possiblePoints.forEach (p) ->
          storystack.append(window.JiraStoryTime.Templates.storyPoint)
          $(storystack.children()[storystack.children().length - 1]).html("\u25BC\u25BC\u25BC  " + p  + "  \u25BC\u25BC\u25BC")
          $(storystack.children()[storystack.children().length - 1]).attr('id', 'story-point-' + p)
          $(storystack.children()[storystack.children().length - 1]).attr('data-story-points', p)

        window.JiraStoryTime.forcedOrderingController.setup()
        window.onbeforeunload = ()  ->
          "Data will be lost if you leave the page, are you sure?"

      else
        storiesView = new window.JiraStoryTime.StoriesColView(window.JiraStoryTime.Stories.backlog_stories)

        # esc
        $(".overlay").keyup (e) ->
          if e.keyCode is 27
            window.JiraStoryTime.Util.abortAllXHR()
            setStoryTime false
            storiesView.close

            $(".overlay").off()
            $(".overlay").find("*").addBack().off()
            $(".overlay")[0].remove()

    
    
  $("#ghx-modes").append window.JiraStoryTime.Templates.storytoggle

  $("#story-toggle").on "click", renderStoryTime
  renderStoryTime()  if isStoryTime()
