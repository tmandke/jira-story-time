window.JiraStoryTime = window.JiraStoryTime || {}
window.JiraStoryTime.Util = {
  deparam: function (query) {
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
  },
  xhrPool:[],
  abortAllXHR: function() {
    window.JiraStoryTime.Util.xhrPool.forEach(function(jqXHR) {
        jqXHR.abort();
    });
    window.JiraStoryTime.Util.xhrPool.length = 0
  }
};
$.ajaxSetup({
    beforeSend: function(jqXHR) {
        window.JiraStoryTime.Util.xhrPool.push(jqXHR);
    },
    complete: function(jqXHR) {
        var index = window.JiraStoryTime.Util.xhrPool.indexOf(jqXHR);
        if (index > -1) {
            window.JiraStoryTime.Util.xhrPool.splice(index, 1);
        }
    }
});
