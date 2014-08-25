window.JiraStoryTime = window.JiraStoryTime || {};
var Story = function ( data ) {
  this.data = data;
  this.linkedIssues = [];
};
Story.id = 'id';
Story.description = 'description';
Story.summary = 'summary';
Story.business = 'customfield_10003';
Story.points = 'customfield_10002';
Story.epic = 'customfield_10007';
Story.NoPoints = '--';
Story.devMode = true;
Story.autoUpdate = true;

Story.prototype.getFullStory = function () {
  return $.ajax({
    url: "/rest/greenhopper/1.0/xboard/issue/details.json?issueIdOrKey=" +
      this.id + "&loadSubtasks=true&rapidViewId=" +
      window.JiraStoryTime.Stories.rapidView,
    context: this
  }).done(this.setMoreData);
};

Story.prototype.setMoreData = function (data) {
  this.moreData = data;
  var _this = this;
  data.fields.forEach(function(f){
    switch (f.id) {
      case Story.summary: _this.summary = f.value; break;
      case Story.points: _this.setPoints(f.value || ""); break;
      case Story.business: _this.business = (f.value || ""); break;
      case Story.description: _this.description = f.html; break;
      case Story.epic: _this.epicColor = window.JiraStoryTime.Stories.epicColor(f.text); break;
    }
  });
  this.buildRelationShips();
};

Story.prototype.render = function( changed_field ){
  var el = $("#story-" + this.data.id);
  var col = el.parent().parent();

  el.find(".story-" + changed_field).html(this[changed_field]);

  if (changed_field == 'linkedStatus'){
    el.attr('data-content', this.linkedStatus);
    var action = (this.linkedStatus == undefined ? 'removeClass' : 'addClass');
    el[action]('linked-story');
    if (this.linkedStatus == 'Blocker')
      el[action]('story-blocker');
    else if (this.linkedStatus == 'Frees')
      el[action]('story-frees');
  }

  if (changed_field == "epicColor")
    el.addClass('epic-color-' + this.epicColor);

  if (changed_field == "points") {
    var pts = this.points == "" ? Story.NoPoints : this.points;
    $('#story-points-' + pts).addClass('has-stories');
    $('#story-points-' + pts).find(this.isCurrent ? '.current-stories' : '.backlog-stories').append(el);

    if (col.find('.backlog-stories').children().length == 0 && col.find('.current-stories').children().length == 0)
      col.removeClass('has-stories');

    $('#story_board').css('min-width', ($('.has-stories').length * 300) + 'px');
  }
};

Story.prototype.setPoints = function(newPoints){
  this.points = newPoints == Story.NoPoints ? "" : newPoints;
  if (Story.devMode != true) {
    $.ajax({
      url: "/rest/greenhopper/1.0/xboard/issue/update-field.json",
      context: document.body,
      type: 'PUT',
      headers: {'Content-Type' : 'application/json' },
      data: '{"fieldId": "' + Story.points + '", "issueIdOrKey": ' + this.id + ', "newValue": "' + this.points + '"}'
    }).done(function(response) {
      console.log(response);
    });
  }
  window.JiraStoryTime.Stories.updateEpics();
};

Story.prototype.buildRelationShips = function (){
  var _this = this;
  this.linkedIssues = [];
  this.moreData.issueLinks.issueLinkTypeEntries.forEach(function(typeEntry){
    var issueType = typeEntry.relationship;
    if (issueType == 'is blocked by')
      issueType = 'Blocker';
    else if (issueType == 'blocks')
      issueType = 'Frees';

    typeEntry.issueLinkEntries.forEach(function (issue){
      _this.linkedIssues.push({
        type: issueType, 
        story: window.JiraStoryTime.Stories.backlog_stories[issue.title],
        key: issue.title
      });
    });

  });
};

Story.prototype.initialize = function ( el ) {
  var _this = this;
  el.append(window.JiraStoryTime.Templates.boardStory);
  dom = el[0].lastChild;
  dom.setAttribute('data-story-id', this.data.id);
  dom.setAttribute('id', "story-" + this.data.id);
  this.isCurrent = ($.inArray(this.data.id, window.JiraStoryTime.Stories.current_stories) > -1);
  dom.setAttribute('draggable', !this.isCurrent);
  
  $(dom).hover(function(){
    _this.linkedIssues.forEach(function(issue){
      if (issue.story != undefined)
        issue.story.linkedStatus = issue.type;
    });
  }, function(){
    _this.linkedIssues.forEach(function(issue){
      if (issue.story != undefined)
        delete issue.story.linkedStatus;
    });
  });

  $(dom).on('pointsChanged', this, function(e, newPoints) {
    e.data.setPoints(newPoints);
  });

  Object.observe(this, Story.observer);
  this.id = this.data.id;
  this.key = this.data.key;
  this.summary = this.data.summary;
  this.points = this.data.estimateStatistic.statFieldValue.value;
  this.getFullStory();
  if (Story.autoUpdate == true)
    this.myInterval = setInterval( function () { _this.getFullStory(); }, 10000 + Math.random() * 5000);
};
Story.prototype.close = function () {
  clearInterval(this.myInterval);
};

Story.observer = function (changes) {
  changes.forEach(function(change){
    // console.log(change.object.data.key + ": " + change.name + " was " + change.type + " to " + change.object[change.name]);
    change.object.render( change.name );
  });
};

window.JiraStoryTime.Story = Story;