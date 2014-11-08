describe 'Views.DropZone', ->
  storyViews  = null
  dropHandler = null
  dropZone    = null
  storyViewId = null

  generateStoryView = () ->
    storyViewId+=1
    {el: $("<div id='story-#{storyViewId}' data-story-id='#{storyViewId}' class='story-item story'>text#{storyViewId}</div>")}

  dataTransferObject = () ->
    dataTransfer = {}
    {
      setData: (k,v) ->
        dataTransfer[k] = v
      getData: (k) ->
        dataTransfer[k]
    }

  beforeEach ->
    storyViewId = 0
    storyViews = []
    storyViews[0] = generateStoryView()
    storyViews[2] = generateStoryView()
    storyViews[1] = generateStoryView()
    dropHandler = jasmine.createSpy('dropHandler')
    dropZone = new JiraStoryTime.Views.DropZone storyViews, 21, dropHandler
    setFixtures(dropZone.el)

  afterEach ->
    dropZone.deconstruct()

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

    it 'sets up drag start event', ->
      e = $.Event('dragstart')
      e.originalEvent = dataTransfer: dataTransferObject()
      storyViews[2].el.trigger e
      expect(e.originalEvent.dataTransfer.getData('storyId')).toBe storyViews[2].el.attr('data-story-id')

    it 'sets up drag enter event', ->
      expect(dropZone.el).not.toHaveClass('over')
      e = $.Event('dragenter')
      dropZone.el.trigger e
      expect(dropZone.el).toHaveClass('over')

    it 'sets up drag leave event on story_board_row_drop_mask', ->
      expect(dropZone.el).not.toHaveClass('over')
      e = $.Event('dragenter')
      dropZone.el.trigger e
      expect(dropZone.el).toHaveClass('over')

      e = $.Event('dragleave')
      dropZone.el.find('.story_board_row_drop_mask').trigger e
      expect(dropZone.el).not.toHaveClass('over')

    it 'sets up drag drop event on story_board_row_drop_mask', ->
      expect(dropZone.el).not.toHaveClass('over')
      e = $.Event('dragenter')
      dropZone.el.trigger e
      expect(dropZone.el).toHaveClass('over')

      e = $.Event('drop')
      e.originalEvent = dataTransfer: dataTransferObject()
      e.originalEvent.dataTransfer.setData('storyId', '123')
      dropZone.el.find('.story_board_row_drop_mask').trigger e
      expect(dropZone.el).not.toHaveClass('over')
      expect(dropHandler).toHaveBeenCalledWith(e, 21, '123')
