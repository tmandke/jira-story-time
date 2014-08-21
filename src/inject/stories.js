window.JiraStoryTime = window.JiraStoryTime || {}
window.JiraStoryTime.Stories = {
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
      _this.backlog_stories = $.grep(response.issues, function(v) { 
        return v.typeName === "Story"; });
      OnDone(_this.backlog_stories);
    }
  }
};
