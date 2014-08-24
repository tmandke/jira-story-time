window.JiraStoryTime = window.JiraStoryTime || {};
var Story = function ( data ) {
  this.data = data;
};
Story.id = 'id';
Story.description = 'description';
Story.summary = 'summary';
Story.business = 'customfield_10003';
Story.points = 'customfield_10002';
Story.epic = 'customfield_10007';
Story.NoPoints = '--';
Story.devMode = true;
Story.autoUpdate = false;

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
      case Story.points: _this.points = (f.value || ""); break;
      case Story.business: _this.business = (f.value || ""); break;
      case Story.description: _this.description = f.html; break;
    }
  });
  if (Story.autoUpdate == true)
    setTimeout( function () {
      _this.getFullStory()} , 60000);
};

Story.prototype.render = function( changed_field ){
  el = $("#story-" + this.data.id);
  el.find(".story-" + changed_field).html(this[changed_field]);
  if (changed_field == "points") {
    var pts = this.points == "" ? Story.NoPoints : this.points;
    $('#story-points-' + pts).addClass('has-stories');
    if (el.parent().children().length == 3)
      el.parent().removeClass('has-stories');
    if (this.isCurrent)
      $('#story-points-' + pts + ' > div:nth-child(2)').after(el);
    else
      $('#story-points-' + pts).append(el);
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
};

Story.prototype.initialize = function ( el ) {
  el.append(window.JiraStoryTime.Templates.boardStory);
  dom = el[0].lastChild;
  dom.setAttribute('data-story-id', this.data.id);
  dom.setAttribute('id', "story-" + this.data.id);
  this.isCurrent = ($.inArray(this.data.id, window.JiraStoryTime.Stories.current_stories) > -1);
  dom.setAttribute('draggable', !this.isCurrent);

  $(dom).on('pointsChanged', this, function(e, newPoints) {
    e.data.setPoints(newPoints);
  });

  Object.observe(this, Story.observer);
  this.id = this.data.id;
  this.key = this.data.key;
  this.summary = this.data.summary;
  this.points = this.data.estimateStatistic.statFieldValue.value;
  this.getFullStory();
};

Story.observer = function (changes) {
  changes.forEach(function(change){
    console.log(change.object.data.key + ": " + change.name + " was " + change.type + " to " + change.object[change.name]);
    change.object.render( change.name );
  });
};

window.JiraStoryTime.Story = Story;