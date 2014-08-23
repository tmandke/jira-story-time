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

    $.when(window.JiraStoryTime.Stories.fetchStories()).done(function (a) {

      $(document.body).append(window.JiraStoryTime.Templates.board);
      [0, 1, 2, 3, 5, 8, 13, 21, window.JiraStoryTime.Story.NoPoints].forEach(function(points){
        $("#story_board").append(window.JiraStoryTime.Templates.boardRow);
        $("#story_board")[0].lastChild.setAttribute('data-story-points', points);
        $("#story_board")[0].lastChild.setAttribute('id', 'story-points-' + points);
        $($("#story_board")[0].lastChild).find('.story_board_row_points').html(points);
      });
      var undefinedCol = $($("#story_board")[0].lastChild);
      window.JiraStoryTime.Stories.backlog_stories.forEach(function(s) {
        s.initialize(undefinedCol)
      });

      window.JiraStoryTime.DragController.setup();
      $("#close_story_board").on("click", function () {
        $('.overlay')[0].remove();
        setStoryTime(false);
        window.JiraStoryTime.Story.autoUpdate = false;
      });
    });
  };

  $("#story-toggle").on("click", renderStoryTime);
  if(isStoryTime())
    renderStoryTime();
 
});
