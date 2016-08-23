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

    it 'addes error when request fails', ->
      JiraStoryTime.Utils.Templates.get('test2.html')
      request = jasmine.Ajax.requests.mostRecent()
      text = "File not found"
      resp = {status: 404, responseText: text }
      request.response(resp)
      expect(JiraStoryTime.Models.Errors[JiraStoryTime.Models.Errors.length - 1].message).toEqual("Error while fetching template 'test2.html' with url '/extension/templates/test2.html'")
      expect(JiraStoryTime.Models.Errors[JiraStoryTime.Models.Errors.length - 1].jqXHR.status).toEqual(resp.status)
      expect(JiraStoryTime.Models.Errors[JiraStoryTime.Models.Errors.length - 1].jqXHR.responseText).toEqual(resp.responseText)

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
