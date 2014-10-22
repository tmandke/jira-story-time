describe 'Views.RegularStoryTime', ->
  backlog     = null
  appState    = null
  regularST   = null
  storyId     = null
  generateStory = (points, business, color) ->
    storyId+=1
    {
      id:         storyId
      isCurrent:  false
      points:     points
      color:      color
      business:   business
    }

  testDZList = (val, args...) ->
    list = regularST.dropZoneLists[val]
    expect(list.length).toEqual(args.length)
    args.forEach (backlogIdx, idx) ->
      if backlogIdx?
        since("dropZoneList[#{val}][#{idx}].story.id: expected #{list[idx].story.id} to be  #{backlog.stories[backlogIdx].id}").
        expect(list[idx].story.id).toEqual(backlog.stories[backlogIdx.toString()].id)
      else
        since("dropZoneList[#{val}][#{idx}] is not a backlog banner").
        expect(list[idx].backlogBanner).toBe true

  beforeEach ->
    storyId = 0
    appState = new JiraStoryTime.Models.ApplicationState()
    backlog =
      stories:
        '1': generateStory()
        '2': generateStory(undefined, 5, 1)
        '3': generateStory(2)
        '4': generateStory(5,2,1)
        '5': generateStory(2,2,2)

    backlog.stories['1'].isCurrent = true
    regularST = new JiraStoryTime.Views.RegularStoryTime appState, backlog
    setFixtures(regularST.el)

  afterEach ->
    regularST.deconstruct()

  describe '.constructor', ->
    it 'distributes stories into proper dropzone lists', ->
      testDZList(undefined, 1, undefined, 2)
      testDZList(1, undefined)
      testDZList(2, undefined, 3, 5)
      testDZList(3, undefined)
      testDZList(5, undefined, 4)
      testDZList(8, undefined)
      testDZList(13, undefined)
      testDZList(21, undefined)

    it 'observes app state points type', ->
      appState.pointsType = 'Business Value'
      Object.deliverChangeRecords regularST.observer
      testDZList(undefined, 1, undefined, 3)
      testDZList(1, undefined)
      testDZList(2, undefined, 4, 5)
      testDZList(3, undefined)
      testDZList(5, undefined, 2)
      testDZList(8, undefined)
      testDZList(13, undefined)
      testDZList(21, undefined)

    it 'observes backlog stories', ->
      backlog.stories['6'] = generateStory()
      backlog.stories['6'].isCurrent = true
      delete backlog.stories['3']
      Object.deliverChangeRecords regularST.observer
      testDZList(undefined, 1, 6, undefined, 2)
      testDZList(1, undefined)
      testDZList(2, undefined, 5)
      testDZList(3, undefined)
      testDZList(5, undefined, 4)
      testDZList(8, undefined)
      testDZList(13, undefined)
      testDZList(21, undefined)

    it 'observes each story', ->
      backlog.stories['3'].isCurrent = true
      Object.deliverChangeRecords regularST.observer
      testDZList(undefined, 1, undefined, 2)
      testDZList(1, undefined)
      testDZList(2, 3, undefined, 5)
      testDZList(3, undefined)
      testDZList(5, undefined, 4)
      testDZList(8, undefined)
      testDZList(13, undefined)
      testDZList(21, undefined)

  describe '#dropHandler', ->
    it "sets story 2's points to 21", ->
      backlog.stories['2'].setProperty = jasmine.createSpy('s2setProperty')
      regularST.dropHandler({}, 21, '2')
      expect(backlog.stories['2'].setProperty).toHaveBeenCalledWith('points', 21)
