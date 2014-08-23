window.JiraStoryTime = window.JiraStoryTime || {}
var Story = function ( data ) {
  this.data = data;
};

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
    switch (f.label) {
      case "Business Value": _this.business = f.value; break;
      case "Description": _this.description = f.html; break;
    }
  });
};

Story.prototype.render = function( changed_field ){
  el = $("#story-" + this.data.id);
  el.find(".story-" + changed_field).html(this[changed_field]);
  if (changed_field == "points") 
    $('#story-points-' + this.points).append(el);
};
Story.prototype.setPoints = function(newPoints){
  this.points = newPoints;
};

Story.prototype.initialize = function ( el ) {
  el.append(window.JiraStoryTime.Templates.boardStory);
  dom = el[0].lastChild;
  dom.setAttribute('data-story-id', this.data.id);
  dom.setAttribute('id', "story-" + this.data.id);
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