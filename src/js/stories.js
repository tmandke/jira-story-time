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

    var backlog_stories = {};
    $.map($.grep(response.issues, function(v) {
      return v.typeName === "Story"; }), function(s){
      backlog_stories[s.key] = new window.JiraStoryTime.Story(s)});

    window.JiraStoryTime.Stories.backlog_stories = backlog_stories;
  },

  epics: [],
  epicColor: function (epic) {
    var color = $.inArray(epic, this.epics);
    if (color < 0) {
      color = this.addEpic(epic);
    }
    return color;
  },
  addEpic: function (epic){
    var color = this.epics.length;
    this.epics.push(epic == 'None' ? '' : epic);
    $('#story_board_epics').append(window.JiraStoryTime.Templates.boardEpic);
    var children = $('#story_board_epics').children();
    var dom = children[children.length-1];
    $(dom).find('.epic-name').html(epic);
    dom.setAttribute('id', 'epic-' + color);
    $(dom).addClass('epic-color-' + color);
    return color;
  },
  updateEpics: function(){
    var epicPoints = {}
    $.map(this.backlog_stories, function(s){
      epicPoints[s.epicColor || 0] = (epicPoints[s.epicColor || 0] || 0) + parseInt(s.points || 0);
    });
    $.map(epicPoints, function(v, k){
      $('#epic-' + k).find('.story-points').html(v);
    });
  }
};
