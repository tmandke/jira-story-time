window.JiraStoryTime = window.JiraStoryTime || {}
window.JiraStoryTime.Stories = {
  Story: function ( data ) {
    this.data = data;
    this.id = data.key;
    this.summary = data.summary;
    this.desc = data.description;
    this.points = data.estimateStatistic.statFieldValue.value;
  },

  fetchStories: function( OnDone ) {
    params = window.JiraStoryTime.Util.deparam(location.href.split("?")[1])
    $.ajax({
      url: "/rest/greenhopper/1.0/xboard/plan/backlog/data.json?rapidViewId=" + params["rapidView"],
      context: document.body
    }).done(this.parseStories(OnDone));
  },

  parseStories: function ( OnDone ) {
    _this = this;
    return function (response) {
      backlog_stories = $.map($.grep(response.issues, function(v) { 
        return v.typeName === "Story"; }), function(s){
        return new _this.Story(s);});
      OnDone(_this.partitionedStories(backlog_stories));
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
