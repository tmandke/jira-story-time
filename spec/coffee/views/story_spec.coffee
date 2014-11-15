describe 'Views.Story', ->
  story     = null
  appState  = null
  basicData = null
  fullData  = null
  storyView = null
  beforeEach ->
    JiraStoryTime.Utils.Templates.get('storyCard.html')
    basicData = getJSONFixture('stories/basic_SYMAN-10.json')
    fullData  = getJSONFixture('stories/full_SYMAN-10.json')
    jasmine.Ajax.install()
    spyOn(JiraStoryTime.Views.Story.prototype, 'render').and.callThrough()
    appState  = new JiraStoryTime.Models.ApplicationState()
    appState.autoUpdate = false
    story     = new JiraStoryTime.Models.Story basicData, 1, appState
    spyOn(story, 'toggelOpen').and.callThrough()
    storyView = new JiraStoryTime.Views.Story story
    setFixtures(storyView.el)

  afterEach ->
    jasmine.Ajax.uninstall()
    storyView.deconstruct()
    story.deconstruct()

  describe '.constructor', ->
    it 'renders story', ->
      expect(JiraStoryTime.Views.Story.prototype.render).toHaveBeenCalledWith()
      expect(storyView.el).toHaveId("story-#{story.id}")
      expect(storyView.el).toHaveAttr("data-story-id", story.id.toString())

    it 'setsup click event to open and observes story', ->
      expect(storyView.el.find('.story-description')).not.toHaveClass("show-me")

      storyView.el.click()
      expect(story.toggelOpen).toHaveBeenCalled()
      Object.deliverChangeRecords storyView.observer
      expect(storyView.el.find('.story-description')).toHaveClass("show-me")

      storyView.el.click()
      expect(story.toggelOpen).toHaveBeenCalled()
      Object.deliverChangeRecords storyView.observer
      expect(storyView.el.find('.story-description')).not.toHaveClass("show-me")

  describe '#_presentPoints', ->
    it 'points number is returned when number is passed', ->
      expect(storyView._presentPoints(1)).toBe 1

    it 'underscore is returned when non number is passed', ->
      expect(storyView._presentPoints(undefined)).toBe "_"

  describe '#render', ->
    it 'updates points and business text', ->
      expect(storyView.el.find(".story-points")).toHaveHtml("_")
      expect(storyView.el.find(".story-business")).toHaveHtml("_")
      story.points = 2
      story.business = 21
      Object.deliverChangeRecords storyView.observer
      expect(storyView.el.find(".story-points")).toHaveHtml("2")
      expect(storyView.el.find(".story-business")).toHaveHtml("21")

    it 'updates key, summary and description text', ->
      expect(storyView.el.find(".story-key")).toHaveHtml("")
      expect(storyView.el.find(".story-summary")).toHaveHtml("")
      expect(storyView.el.find(".story-description")).toHaveHtml("")
      story.key = 'k1'
      story.summary = 's1'
      story.description = 'd1'
      Object.deliverChangeRecords storyView.observer
      expect(storyView.el.find(".story-key")).toHaveHtml("k1")
      expect(storyView.el.find(".story-summary")).toHaveHtml("s1")
      expect(storyView.el.find(".story-description")).toHaveHtml("d1")

    it 'updates draggablility based on isCurrent', ->
      expect(storyView.el).toHaveAttr("draggable", "true")
      story.isCurrent = true
      Object.deliverChangeRecords storyView.observer
      expect(storyView.el).toHaveAttr("draggable", "false")
      story.isCurrent = false
      Object.deliverChangeRecords storyView.observer
      expect(storyView.el).toHaveAttr("draggable", "true")

    it 'updates subset-color', ->
      expect(storyView.el).toHaveClass("subset-color-undefined")
      expect(storyView.el).not.toHaveClass("subset-color-1")
      story.color = 1
      Object.deliverChangeRecords storyView.observer
      expect(storyView.el).not.toHaveClass("subset-color-undefined")
      expect(storyView.el).toHaveClass("subset-color-1")

    it 'toggles description open and close', ->
      expect(storyView.el.find('.story-description')).not.toHaveClass("show-me")
      story.isOpen = true
      Object.deliverChangeRecords storyView.observer
      expect(storyView.el.find('.story-description')).toHaveClass("show-me")
      story.isOpen = false
      Object.deliverChangeRecords storyView.observer
      expect(storyView.el.find('.story-description')).not.toHaveClass("show-me")

    it 'toggles visibility on and off', ->
      expect(storyView.el).not.toHaveClass("hide-me")
      story.visible = false
      Object.deliverChangeRecords storyView.observer
      expect(storyView.el).toHaveClass("hide-me")
      story.visible = true
      Object.deliverChangeRecords storyView.observer
      expect(storyView.el).not.toHaveClass("hide-me")

  describe '#deconstruct', ->
    it 'calls unobserves all', ->
      spyOn(storyView, 'unobserveAll').and.callThrough()
      storyView.deconstruct()
      expect(storyView.unobserveAll).toHaveBeenCalled()

    it 'el is removed for dom', ->
      expect($("##{jasmine.getFixtures().containerId}")).toContainElement "#story-#{story.id}"
      storyView.deconstruct()
      expect($("##{jasmine.getFixtures().containerId}")).not.toContainElement "#story-#{story.id}"

