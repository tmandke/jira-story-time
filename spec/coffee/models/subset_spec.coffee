describe 'Models.Subset', ->
  storyId     = null
  epic        = null
  stories     = null
  generateStory = (obj, points, business) ->
    storyId+=1
    {
      id:           storyId
      points:       points
      business:     business
      subset_epic:  obj
      visible_epic: true
    }

  beforeEach ->
    storyId = 0
    appState = new JiraStoryTime.Models.ApplicationState()

    stories = {}
    stories['1'] = generateStory(undefined, 1, 2)

    epic = new JiraStoryTime.Models.Subset 'epic', 'test', 1, stories
    stories['2'] = generateStory(epic, undefined, 5)
    stories['3'] = generateStory(epic, 3)
    stories['4'] = generateStory(epic, 5, 2)
    stories['5'] = generateStory(epic, 2, 2)
    Object.deliverChangeRecords epic.observer

  afterEach ->
    epic.deconstruct()

  describe ".constructor", ->
    describe "observes stories hash", ->
      it "comptes the correct points", ->
        expect(epic.business).toBe 9
        expect(epic.points).toBe 10
        delete stories['4']
        Object.deliverChangeRecords epic.observer
        expect(epic.business).toBe 7
        expect(epic.points).toBe 5

    describe "observes each story", ->
      it "comptes the correct points", ->
        stories['3'].business = 21
        stories['1'].points   = 8
        Object.deliverChangeRecords epic.observer
        expect(epic.business).toBe 30
        expect(epic.points).toBe 10
        stories['1'].subset_epic = epic
        Object.deliverChangeRecords epic.observer
        expect(epic.business).toBe 32
        expect(epic.points).toBe 18

  describe "#toggleVisibility", ->
      it "switch all stories but 1 to not visible", ->
        epic.toggleVisibility()
        expect(stories['1'].visible_epic).toBe true
        expect(stories['2'].visible_epic).toBe false
        expect(stories['3'].visible_epic).toBe false
        expect(stories['4'].visible_epic).toBe false
        expect(stories['5'].visible_epic).toBe false

      it "all stories become visible when toggeled again", ->
        epic.toggleVisibility()
        epic.toggleVisibility()
        expect(stories['1'].visible_epic).toBe true
        expect(stories['2'].visible_epic).toBe true
        expect(stories['3'].visible_epic).toBe true
        expect(stories['4'].visible_epic).toBe true
        expect(stories['5'].visible_epic).toBe true
