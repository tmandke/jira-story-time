window.JiraStoryTime = window.JiraStoryTime || {}
window.JiraStoryTime.Templates = {
  fetchAll: function ( OnDone ) {
    _this = this;
    counter = 0;
    tmpls = [ 'board', 'storytoggle', 'boardRow', 'boardStory', 'boardEpic' ];

    $.map(tmpls, function (file_name) {
      $.ajax({
        url: chrome.extension.getURL('/src/templates/' + file_name + '.html'),
          context: document.body
        }).done(function (response) {
            _this[file_name] = response;
            counter = counter + 1;
            if(counter == tmpls.length) {
                OnDone();
            }
        });

    });
  }
}
