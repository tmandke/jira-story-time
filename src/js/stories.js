window.JiraStoryTime = window.JiraStoryTime || {}
window.JiraStoryTime.Stories = {
  fetchStories: function() {
    params = window.JiraStoryTime.Util.deparam(location.href.split("?")[1]);
    this.rapidView = params["rapidView"];
    return $.ajax({
      url: "/rest/greenhopper/1.0/xboard/plan/backlog/data.json?rapidViewId=" + this.rapidView,
      context: document.body
    }).done(this.parseStories);
  },

  parseStories: function ( response ) {
    window.JiraStoryTime.Stories.current_stories = $.map(response.sprints, function (sprint){
      return (sprint.state == "ACTIVE" ? sprint.issuesIds : null);
    });

    var backlog_stories = $.map($.grep(response.issues, function(v) {
      return v.typeName === "Story"; }), function(s){
      return new window.JiraStoryTime.Story(s)});
    window.JiraStoryTime.Stories.backlog_stories = backlog_stories;
    return backlog_stories;
  }
};
