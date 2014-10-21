class JiraStoryTime.Views.ApplicationLauncher extends JiraStoryTime.Utils.Observer
  confirmString: "Data will be lost if you leave the page, are you sure?"

  constructor: (@baseElem, @applicationState) ->
    super()
    @baseElem.find("#ghx-modes").append(
      JiraStoryTime.Utils.Templates.get('storyTimeToggle.html'))

    @observe @applicationState
    @baseElem.find("#story-toggle").on "click", @renderStoryTime
    @launch() if @applicationState.storyTimeActive is true

  renderStoryTime: =>
    @applicationState.storyTimeActive = true

  overlay: =>
    @baseElem.find('.overlay')

  onObservedChange: (change) =>
    if change.name is 'storyTimeActive'
      if @applicationState.storyTimeActive is true
        @launch()
      else
        @backlog.deconstruct()
        @menuView.deconstruct()
        delete @backlog
        window.JiraStoryTime.Util.abortAllXHR()
        @overlay().off()
        @overlay().find("*").addBack().off()
        @overlay()[0].remove()

    else if change.name is 'pointsType'
      @updateBannerTitle()

  updateBannerTitle: () =>
    @baseElem.find("#story-board-banner-title").html(
      "Storytime: #{$.trim(@baseElem.find("#ghx-board-name").html())} " +
      "(#{@applicationState.pointsType})")

  launch: =>
    @baseElem.append window.JiraStoryTime.Utils.Templates.get('board.html')
    @overlay().focus()
    @updateBannerTitle()
    cssUrl = JiraStoryTime.Utils.Templates.templateUrl 'styles.css'
    @overlay().prepend("<link href='#{cssUrl}' media='all' rel='stylesheet' type='text/css'>")
    @overlay().keyup(@onKeyup)
    @_launchMenu()
    @_createBacklog()
    @_createBoard()

  _launchMenu: =>
    @menuView = new JiraStoryTime.Views.ApplicationMenu(@applicationState)
    @overlay().find("#story-board-banner").append @menuView.el

  _createBacklog: =>
    rapidView = JiraStoryTime.Utils.Params.getCurrentParams().rapidView
    @backlog = new JiraStoryTime.Models.Backlog(rapidView, @applicationState)

  _createBoard: =>
    @board = new JiraStoryTime.Views.RegualrStoryTime(@applicationState, @backlog)
    @board.el.insertBefore(@overlay().find('#story-unassigned-placeholder'))

  onKeyup: (e) =>
    if e.keyCode is 27 #Esc
      if @confirmExitIfNessary()
        @applicationState.storyTimeActive = false


  confirmExitIfNessary: =>
    if @applicationState.view is 'Forced'
      confirm(@confirmString)
    else
      true
