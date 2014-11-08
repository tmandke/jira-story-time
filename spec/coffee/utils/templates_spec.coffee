describe 'Utils.Templates', ->
  describe '.get', ->
    beforeEach ->
      jasmine.Ajax.install()

    afterEach ->
      jasmine.Ajax.uninstall()

    it 'fetches the test template only once', ->
      jasmine.Ajax.stubRequest(
        '/extension/templates/test.html'
      ).andReturn(
        contentType: 'plain/text'
        responseText: '<p>awesome test string</p>'
      )

      expect(JiraStoryTime.Utils.Templates.get('test.html')).toBe('<p>awesome test string</p>')
      expect(JiraStoryTime.Utils.Templates.get('test.html')).toBe('<p>awesome test string</p>')
      expect(JiraStoryTime.Utils.Templates.get('test.html')).toBe('<p>awesome test string</p>')
      expect(JiraStoryTime.Utils.Templates.get('test.html')).toBe('<p>awesome test string</p>')
      expect(jasmine.Ajax.requests.count()).toBe 1
  describe '.templateUrl', ->
    beforeEach ->
      JiraStoryTime.Utils.Templates.templateUrl.and.callThrough()
      chrome.extension =
        getURL: (fileName) ->
          "/extension#{fileName}"
    afterEach ->
      delete chrome.extension

    it 'returns proper url', ->
      expect(JiraStoryTime.Utils.Templates.templateUrl('test.html')).toBe '/extension/templates/test.html'
