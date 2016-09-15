describe 'Views.Errors', ->
  errorsView     = null
  errors         = null
  el             = null

  beforeEach ->
    errors = []
    el = $(setFixtures("<ul id='error-banner'></ul>").children()[0])
    errorsView = new JiraStoryTime.Views.Errors errors

  afterEach ->
    errorsView.deconstruct()

  describe '.constructor', ->
    it 'renders nothing', ->
      expect(el.children().length).toEqual(0)

  describe '#render & #onObservedChange', ->
    it 'renders error', ->
      errors.push(new JiraStoryTime.Models.Error "doomed", {status:500, responseText: "doomed"})
      Object.deliverChangeRecords errorsView.observer

      expect(el.children().length).toEqual(1)
      expect(el.find(".error-message")).toHaveHtml("doomed")
      expect(el.find(".possible-solution")).toContainHtml("Please do check if there is already")
      expect(el.find(".response-status")).toHaveHtml(500)
      expect(el.find(".response-text")).toHaveHtml("doomed")

    it 'renders 2nd error', ->
      errors.push(new JiraStoryTime.Models.Error "doomed", {status:500, responseText: "doomed"})
      Object.deliverChangeRecords errorsView.observer

      expect(el.children().length).toEqual(1)
      expect($(el.children()[0]).find(".error-message")).toHaveHtml("doomed")
      expect($(el.children()[0]).find(".possible-solution")).toContainHtml("Please do check if there is already")
      expect($(el.children()[0]).find(".response-status")).toHaveHtml(500)
      expect($(el.children()[0]).find(".response-text")).toHaveHtml("doomed")

      errors.push(new JiraStoryTime.Models.Error "doomed2", {status:501, responseText: "doomed2"})
      Object.deliverChangeRecords errorsView.observer

      expect(el.children().length).toEqual(2)
      expect($(el.children()[1]).find(".error-message")).toHaveHtml("doomed2")
      expect($(el.children()[1]).find(".possible-solution")).toContainHtml("Please do check if there is already")
      expect($(el.children()[1]).find(".response-status")).toHaveHtml(501)
      expect($(el.children()[1]).find(".response-text")).toHaveHtml("doomed2")
