describe 'Models.Error', ->
  describe '.constructor', ->
    it 'sets message and xhr', ->
      error = new JiraStoryTime.Models.Error("msg", "xhr")
      expect(error.message).toEqual("msg")
      expect(error.jqXHR).toEqual("xhr")

  describe '#responseStatus', ->
    it 'returns xhr status code', ->
      error = new JiraStoryTime.Models.Error("msg", {status: 500, responseText: "nothing is working"})
      expect(error.responseStatus()).toEqual(500)

  describe '#responseText', ->
    it 'returns response text', ->
      error = new JiraStoryTime.Models.Error("msg", {status: 500, responseText: "nothing is working"})
      expect(error.responseText()).toEqual("nothing is working")

  describe '#possibleSolution', ->
    it 'returns a no known solution message', ->
      error = new JiraStoryTime.Models.Error("msg", {status: 500, responseText: "nothing is working"})
      expect(error.possibleSolution()).toContain('Please do check if there is already a issue')

    it 'returns request aborted message', ->
      error = new JiraStoryTime.Models.Error("msg", {status: 0})
      expect(error.possibleSolution()).toContain('Seems like the request was aborted.')

    it 'returns solution for fields missing', ->
      text = "{\"errorMessages\":[],\"errors\":{\"customfield_10026\":\"Field 'customfield_10026' cannot be set. It is not on the appropriate screen, or unknown.\"}}"
      error = new JiraStoryTime.Models.Error("msg", {status: 401, responseText: text})
      expect(error.possibleSolution()).toContain('Add the field to Projects Screen.')
      expect(error.possibleSolution()).toContain("https://confluence.atlassian.com/adminjiracloud/defining-a-screen-776636475.html#Definingascreen-Configuringascreen'stabsandfields")

  describe '#_link', ->
    it 'returns link which opens it in new tab', ->
      error = new JiraStoryTime.Models.Error("msg", {status: 500, responseText: "nothing is working"})
      expect(error._link("abc", "xyz")).toEqual('<a href="abc" target="_blank">xyz</a>')
