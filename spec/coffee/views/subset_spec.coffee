describe 'Views.Subset', ->
  subset = null
  subsetView = null
  beforeEach ->
    JiraStoryTime.Utils.Templates.get('subset.html')
    subset =
      points: 10
      business: 20
      toggleVisibility: jasmine.createSpy('subset.toggleVisibility')
      deconstruct: jasmine.createSpy('subset.deconstruct')
      name: 'test subset'
      subsetVar: 'aaa'
      color: 9

    subsetView = new JiraStoryTime.Views.Subset subset
    setFixtures(subsetView.el)

  afterEach ->
    subsetView.deconstruct()

  describe '.constructor', ->
    it 'adds color class, sets name and points', ->
      expect(subsetView.el).toHaveClass('epic-color-9')
      expect(subsetView.el).toContainText('test subset')
      expect(subsetView.el).toContainText('10 / 20')

    it 'observes subset', ->
      subset.points = 13
      Object.deliverChangeRecords subsetView.observer
      expect(subsetView.el).toContainText('13 / 20')

    it 'toggles subset visibility', ->
      subsetView.el.find('label').click()
      expect(subset.toggleVisibility).toHaveBeenCalled()
