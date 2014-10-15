describe 'Templates', ->
  describe '.get', ->
    beforeEach ->
      jasmine.Ajax.install()
      spyOn(JiraStoryTime.Utils.Templates, 'templateUrl').and.callFake (fileName) ->
        "/extension/templates/#{fileName}"

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
