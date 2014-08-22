window.JiraStoryTime.Templates.fetchAll( function () {
  function isStoryTime () {
    return window.JiraStoryTime.Util.deparam(location.href.split("?")[1])['story_time'] == "true";
  };

  function setStoryTime (st) {
    params = window.JiraStoryTime.Util.deparam(location.href.split("?")[1]);
    params['story_time'] = st;
    newUrl = location.href.split("?")[0] + "?" + $.param(params);
    history.pushState(null, null, newUrl);
  };

  $("#ghx-modes").append(window.JiraStoryTime.Templates.storytoggle);
  function renderStoryTime() {
    if( !isStoryTime() )
      setStoryTime(true);

    var renderStory = function (dom, story) {
      dom.append(window.JiraStoryTime.Templates.boardStory);
      dom = $(dom[0].lastChild);
      dom[0].setAttribute('data-story-id', story.id);
      dom.find(".story_id").html(story.id);
      dom.find(".story_summary").html(story.summary);
    }

    var renderRow = function (points, stories) {
      $("#story_board").append(window.JiraStoryTime.Templates.boardRow);
      $("#story_board")[0].lastChild.setAttribute('data-story-points', points);
      $($("#story_board")[0].lastChild).find('.story_board_row_points').html(points);
      $.each(stories, function() {
        renderStory($($("#story_board")[0].lastChild), this);
      });
    }

    window.JiraStoryTime.Stories.fetchStories( function ( partitioned_backlog_stories ) {
      $(document.body).append(window.JiraStoryTime.Templates.board);
      $.each(partitioned_backlog_stories, renderRow);

      window.JiraStoryTime.DragController.setup();
      $("#close_story_board").on("click", function () {
        $('.overlay')[0].remove();
        setStoryTime(false);
      });
    });

    // $.ajax({
    //   url: "/rest/greenhopper/1.0/xboard/issue/update-field.json",
    //   context: document.body,
    //   type: 'PUT',
    //   headers: {'Content-Type' : 'application/json' },
    //   data: '{"fieldId": "customfield_10002", "issueIdOrKey": 10517, "newValue": "1"}'
    // }).done(function(response) {
    //   console.log(response);
    // });

  };

  $("#story-toggle").on("click", renderStoryTime);
  if(isStoryTime())
    renderStoryTime();
 
});
