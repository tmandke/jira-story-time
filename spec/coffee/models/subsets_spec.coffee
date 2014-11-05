describe 'Models.Subsets', ->
  storyId     = null
  epics       = null
  backlog     = null
  stories     = null
  generateStory = (epic, points, business) ->
    storyId+=1
    {
      id:         storyId
      points:     points
      business:   business
      epic:       epic
      visible:    true
    }

  beforeEach ->
    storyId = 0
    appState = new JiraStoryTime.Models.ApplicationState()

    stories = {}
    stories['1'] = generateStory(undefined, 1, 2)
    stories['2'] = generateStory("abc", undefined, 5)
    backlog =
      stories: stories

    epics = new JiraStoryTime.Models.Subsets backlog, 'epic'
    stories['3'] = generateStory("aaa", 3)
    stories['4'] = generateStory("abc", 5, 2)
    stories['5'] = generateStory("aaa", 2, 2)
    Object.deliverChangeRecords epics.observer

  afterEach ->
    epics.deconstruct()

  describe ".constructor", ->
    describe "observes stories hash", ->
      it "creates 3 epics", ->
        expect(Object.keys(epics.subsets).length).toBe 3

      it "deletiton of a story should not delete its epic", ->
        delete stories['1']
        Object.deliverChangeRecords epics.observer
        expect(Object.keys(epics.subsets).length).toBe 3

    describe "observes each story", ->
      it "change in epic results in color change", ->
        expect(stories['1'].subset_epic.color).toBe 1
        stories['1'].epic = "abc"
        Object.deliverChangeRecords epics.observer
        expect(stories['1'].subset_epic.color).toBe 2
