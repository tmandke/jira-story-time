window.JiraStoryTime.Templates.fetchAll( function () {
  $("#ghx-modes").append(window.JiraStoryTime.Templates.storytoggle);
  $("#story-toggle").on("click", function () {

    window.JiraStoryTime.Stories.fetchStories( function ( backlog_stories ) {
      backlog_stories_names = jQuery.map( backlog_stories, function( s ) { return ( "[" + s.key + "] " + s.summary ); });
      $(document.body).append(window.JiraStoryTime.Templates.board);
      $(".overlay")[0].setAttribute('style', 'display:block');
      $("#story_board").html(backlog_stories_names.join("</br>"));
      $("#close_story_board").on("click", function () {
        $('.overlay')[0].remove();
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

  });

});
