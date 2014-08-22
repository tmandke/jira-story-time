window.JiraStoryTime = window.JiraStoryTime || {}
window.JiraStoryTime.Stories = {
  Story: function ( data ) {
    this.data = data;
    this.id = data.key;
    this.summary = data.summary;
    this.points = data.estimateStatistic.statFieldValue.value;
    this.getFullStory = function () {
      return $.ajax({
        url: "/rest/greenhopper/1.0/xboard/issue/details.json?issueIdOrKey=" +
          this.id + "&loadSubtasks=true&rapidViewId=" +
          window.JiraStoryTime.Stories.rapidView,
        context: document.body
      }).done(function(data){
        $.map(window.JiraStoryTime.Stories.backlog_stories, function(s) {
          if (s.id == data.key)
            s.moreData = data;
        });
      });

    };
  },

  fetchStories: function( OnDone ) {
    params = window.JiraStoryTime.Util.deparam(location.href.split("?")[1]);
    this.rapidView = params["rapidView"];
    $.ajax({
      url: "/rest/greenhopper/1.0/xboard/plan/backlog/data.json?rapidViewId=" + this.rapidView,
      context: document.body
    }).done(this.parseStories(OnDone));
  },

  parseStories: function ( OnDone ) {
    return function (response) {
      backlog_stories = $.map($.grep(response.issues, function(v) { 
        return v.typeName === "Story"; }), function(s){
        return new window.JiraStoryTime.Stories.Story(s)});
      window.JiraStoryTime.Stories.backlog_stories = backlog_stories;
      $.when($.map( backlog_stories, function (s) {
        return s.getFullStory();})).done(function(){
        OnDone(window.JiraStoryTime.Stories.partitionedStories(backlog_stories));
      });
    }
  },

  partitionedStories: function (backlog_stories) {
    partitioned_stories = {
      "undefined": [],
      "0": [],
      "1": [],
      "2": [],
      "3": [],
      "5": [],
      "8": [],
      "13": [],
      "21": []
    }
    $.map(backlog_stories, function ( s ) {
      partitioned_stories[s.points] = partitioned_stories[s.points] || [];
      partitioned_stories[s.points].push(s);
    });
    return partitioned_stories;
  }
};
