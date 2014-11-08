class window.JiraStoryTime.Utils.Templates
  @templates: {}

  @get: (templateName) =>
    if @templates[templateName]
      @templates[templateName]
    else
      $.ajax(
        url: @templateUrl(templateName)
        context: document.body
        async: false
      ).done (tmpl) =>
        @templates[templateName] = tmpl
      @templates[templateName]

  @templateUrl: (fileName) ->
    chrome.extension.getURL("/templates/" + fileName)