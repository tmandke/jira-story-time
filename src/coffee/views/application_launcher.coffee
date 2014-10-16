class JiraStoryTime.Views.ApplicationLauncher extends JiraStoryTime.Utils.Observer
  confirmString: "Data will be lost if you leave the page, are you sure?"

  constructor: (@baseElem, @applicationState) ->
    super()
    @baseElem.find("#ghx-modes").append(
      JiraStoryTime.Utils.Templates.get('storyTimeToggle.html'))

    @observe @applicationState
    @baseElem.find("#story-toggle").on "click", @renderStoryTime

  renderStoryTime: =>
    @applicationState.storyTimeActive = true

  overlay: =>
    @baseElem.find('.overlay')

  onObservedChange: (change) =>
    if change.name is 'storyTimeActive'
      if @applicationState.storyTimeActive is true
        @baseElem.append window.JiraStoryTime.Utils.Templates.get('board.html')
        @overlay().focus()
        @baseElem.find("#story-board-banner").html("Storytime: #{$.trim(@baseElem.find("#ghx-board-name").html())}")
        cssUrl = JiraStoryTime.Utils.Templates.templateUrl 'styles.css'
        @overlay().prepend("<link href='#{cssUrl}' media='all' rel='stylesheet' type='text/css'>")
        @overlay().keyup(@onKeyup)
      else
        window.JiraStoryTime.Util.abortAllXHR()
        @overlay().off()
        @overlay().find("*").addBack().off()
        @overlay()[0].remove()

  onKeyup: (e) =>
    if e.keyCode is 27 #Esc
      if @confirmExitIfNessary()
        @applicationState.storyTimeActive = false


  confirmExitIfNessary: =>
    if @applicationState.view is 'Forced'
      confirm(@confirmString)
    else
      true
