class window.JiraStoryTime.TopBarView
  confirmString: "Data will be lost if you leave the page, are you sure?"
  isStoryPointsType: null

  isRegularBoardType: null

  constructor: ->
    if @isStoryTime()
      @applyRadioChange()

  applyRadioChange: =>
    @isStoryPointsType = @forceBool $('#pointsType-sp').prop('checked')
    @isRegularBoardType = @forceBool $('#boardType-r').prop('checked')
    @boardTypeChange()

  forceBool: (val) =>
    if val? then val else true

  boardTypeChange: =>
    @closeCurrentView()
    window.JiraStoryTime.Stories.resetEpics()
    @setStoryTime true  unless @isStoryTime()
    $.when(window.JiraStoryTime.Stories.fetchStories()).done =>
      @openNewView()
      type = if @isStoryPointsType then 'points' else 'business'
      if @isRegularBoardType
        @currentView = new window.JiraStoryTime.StoriesColView(window.JiraStoryTime.Stories.backlog_stories, type)
        window.onbeforeunload = null
      else
        @currentView = new window.JiraStoryTime.ForcedOrderingView(window.JiraStoryTime.Stories.backlog_stories, type)
        window.onbeforeunload = @confirmString

  closeCurrentView: =>
    if @currentView?
      window.JiraStoryTime.Util.abortAllXHR()
      @setStoryTime false
      @currentView.close

      $(".overlay").off()
      $(".overlay").find("*").addBack().off()
      $(".overlay")[0].remove()
      @currentView = null

  openNewView: =>
    $(document.body).append window.JiraStoryTime.Utils.Templates.get('board.html')
    $(".overlay").focus()
    $("#story-board-banner").html("Storytime: #{$("#ghx-board-name").html()}")
    $(".overlay").prepend("<link href='#{chrome.extension.getURL("/templates/styles.css")}' media='all' rel='stylesheet' type='text/css'>")
    window.JiraStoryTime.Stories.addEpic "None"
    $(".overlay").keyup(@onEsc)
    @setRadios()
    $("input[name=boardType]:radio").change(@applyRadioChange)
    $("input[name=pointsType]:radio").change(@applyRadioChange)
    $(".typeSwitcher").on('click', @confirmExitIfNessary)


  setRadios: =>
    @setAttrChecked(if @isStoryPointsType then "#pointsType-sp" else "#pointsType-bp")
    @setAttrChecked(if @isRegularBoardType then "#boardType-r" else "#boardType-fo")

  setAttrChecked: (selector) ->
    $(selector)[0].setAttribute('checked', true)

  isStoryTime: ->
    window.JiraStoryTime.Util.deparam(location.href.split("?")[1])["story_time"] is "true"

  setStoryTime: (st) ->
    params = window.JiraStoryTime.Util.deparam(location.href.split("?")[1])
    params["story_time"] = st
    newUrl = location.href.split("?")[0] + "?" + $.param(params)
    history.pushState null, null, newUrl


  onEsc: (e) =>
    if e.keyCode is 27
      if @confirmExitIfNessary()
        @closeCurrentView()

  confirmExitIfNessary: =>
    if @isRegularBoardType == false
      confirm(@confirmString)
    else
      true
