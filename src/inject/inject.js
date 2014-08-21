function deparam(query) {
    var pairs, i, keyValuePair, key, value, map = {};
    // remove leading question mark if its there
    if (query.slice(0, 1) === '?') {
        query = query.slice(1);
    }
    if (query !== '') {
        pairs = query.split('&');
        for (i = 0; i < pairs.length; i += 1) {
            keyValuePair = pairs[i].split('=');
            key = decodeURIComponent(keyValuePair[0]);
            value = (keyValuePair.length > 1) ? decodeURIComponent(keyValuePair[1]) : undefined;
            map[key] = value;
        }
    }
    return map;
}
var app = angular.module('Story Time', []);

var html = document.querySelector('html');
html.setAttribute('ng-app', '');
html.setAttribute('ng-csp', '');

var viewport = document.body;
viewport.setAttribute('ng-controller', 'MainController');
app.controller('MainController', function ($scope) {});

var myDirective = document.createElement('div');
myDirective.setAttribute('my-directive', '');
document.body.appendChild(myDirective);

app.directive('myDirective', [ '$sce', function($sce) {
  return {
    restrict: 'EA',
    replace: true,
    templateUrl: $sce.trustAsResourceUrl(chrome.extension.getURL('src/templates/board.html'))
  };
}]);

angular.bootstrap(html, ['Story Time'], []);

params = deparam(location.href.split("?")[1])
console.log(params)
$("#ghx-modes").append('<a id="story-toggle" class="aui-button" data-tooltip="Plan mode ( 4 )" tabindex="0" original-title="">Story</a>');
$("#story-toggle").on("click", function () {

  $.ajax({
    url: "/rest/greenhopper/1.0/xboard/plan/backlog/data.json?rapidViewId=" + params["rapidView"],
    context: document.body
  }).done(function(response) {
    console.log(response);
    $(".overlay")[0].setAttribute('style', 'display:block');
    backlog_stories = $.grep(response.issues, function(v) {
      return v.typeName === "Story";
    });
    backlog_stories_names = jQuery.map( backlog_stories, function( n ) {
  return ( "[" + n.key + "] " + n.summary );});
    $("#story_board").html(backlog_stories_names.join("</br>"));
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
