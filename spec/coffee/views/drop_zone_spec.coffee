describe 'Views.DropZone', ->
  storyViews  = null
  dropHandler = null
  dropZone    = null
  storyViewId = null
  generateStoryView = () ->
    storyViewId+=1
    {el: $("<div id='story-#{storyViewId}' class='story-item'>text#{storyViewId}</div>")}

  beforeEach ->
    storyViewId = 0
    storyViews = []
    storyViews[0] = generateStoryView()
    storyViews[2] = generateStoryView()
    storyViews[1] = generateStoryView()
    dropZone = new JiraStoryTime.Views.DropZone storyViews, 21, dropHandler
    setFixtures(dropZone.el)

  describe '.constructor', ->
    it 'adds all stories to .stories elemnt sequentally', ->
      stories = dropZone.el.find('.stories').children()
      storyViews.forEach (sv, idx) ->
        expect(stories[idx]).toHaveText(sv.el.html())

    it 'sets basic drop zone dom properties', ->
      expect(dropZone.el).toHaveAttr("data-story-points", "21")
      expect(dropZone.el).toHaveId("story-points-21")
      expect(dropZone.el.find('.story_board_row_points')).toHaveText('21')

    it 'observes storyViews', ->
      storyViews.splice 0, 0, generateStoryView()
      storyViews.splice 3, 1, generateStoryView(), generateStoryView()
      storyViews.push generateStoryView()

      Object.deliverChangeRecords dropZone.observer
      stories = dropZone.el.find('.stories').children()
      console.log storyViews, stories
      storyViews.forEach (sv, idx) ->
        expect(stories[idx]).toHaveText(sv.el.html())
