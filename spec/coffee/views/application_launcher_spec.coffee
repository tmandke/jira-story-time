describe 'Views.ApplicationLauncher', ->
  dummyJiraPage = null
  launcher = null
  appState = null
  beforeEach ->
    loadFixtures('dummy_jira_page.html')
    dummyJiraPage = $('#dummy-jira-page')
    appState = new JiraStoryTime.Models.ApplicationState
    spyOn(JiraStoryTime.Views, 'ApplicationMenu').and.returnValue(
      el: $('<div id="JST-menu-test-elm"></div>')
    )

  describe 'with storyTime active', ->
    beforeEach ->
      appState.storyTimeActive = true
      spyOn(JiraStoryTime.Views.ApplicationLauncher.prototype, 'launch')
      launcher = new JiraStoryTime.Views.ApplicationLauncher(dummyJiraPage, appState)

    it 'auto adds overlay', ->
      expect(dummyJiraPage.find('#ghx-modes').find('#story-toggle')[0]).toBeInDOM()
      expect(JiraStoryTime.Views.ApplicationLauncher.prototype.launch).toHaveBeenCalled()

  describe 'with storyTime inactive', ->
    beforeEach ->
      launcher = new JiraStoryTime.Views.ApplicationLauncher(dummyJiraPage, appState)

    it 'adds a StoryTime button to the "ghx-modes"', ->
      expect(dummyJiraPage.find('#ghx-modes').find('#story-toggle')[0]).toBeInDOM()

    it '"#story-toggle" click makes storyTimeActive to true', ->
      dummyJiraPage.find('#ghx-modes').find('#story-toggle').click()
      expect(appState.storyTimeActive).toBe true

    it 'pressing esc keyboard makes storyTimeActive to false', ->
      appState.storyTimeActive = true
      Object.deliverChangeRecords launcher.observer
      e = $.Event('keyup')
      e.keyCode = 67
      dummyJiraPage.find('.overlay').trigger(e)
      expect(appState.storyTimeActive).toBe true

      e.keyCode = 27
      dummyJiraPage.find('.overlay').trigger(e)
      expect(appState.storyTimeActive).toBe false

    it 'pressing esc keyboard makes overlay go away esc should not do anything', ->
      appState.storyTimeActive = true
      Object.deliverChangeRecords launcher.observer
      e = $.Event('keyup')
      e.keyCode = 27
      dummyJiraPage.find('.overlay').trigger(e)
      expect(appState.storyTimeActive).toBe false
      Object.deliverChangeRecords launcher.observer
      expect(dummyJiraPage).not.toContainElement('.overlay')
      spyOn(launcher, 'confirmExitIfNessary')
      dummyJiraPage.find('.overlay').trigger(e)
      expect(launcher.confirmExitIfNessary).not.toHaveBeenCalled()

    it '"#story-toggle" click should add overlay, banner and stylesheet', ->
      dummyJiraPage.find('#ghx-modes').find('#story-toggle').click()
      Object.deliverChangeRecords launcher.observer
      expect(dummyJiraPage).toContainElement('.overlay')
      expect(dummyJiraPage.find('.overlay')).toBeFocused()
      expect(dummyJiraPage.find('#story-board-banner')).toContainText('Storytime: Test Board (Story Points)')
      expect(dummyJiraPage).toContainElement('.overlay link[type="text/css"]')

    it 'points type update should chaneg the banner', ->
      dummyJiraPage.find('#ghx-modes').find('#story-toggle').click()
      Object.deliverChangeRecords launcher.observer
      expect(dummyJiraPage.find('#story-board-banner')).toContainText('Storytime: Test Board (Story Points)')
      appState.pointsType = "Business Value"
      Object.deliverChangeRecords launcher.observer
      expect(dummyJiraPage.find('#story-board-banner')).toContainText('Storytime: Test Board (Business Value)')

    it 'should ask for confirmation when closing if view = "Forced"', ->
      appState.storyTimeActive = true
      appState.view = 'Forced'
      Object.deliverChangeRecords launcher.observer
      spyOn(window, 'confirm').and.returnValue(true)
      e = $.Event('keyup')
      e.keyCode = 27
      dummyJiraPage.find('.overlay').trigger(e)
      expect(window.confirm).toHaveBeenCalled()

    it 'has a menu element added', ->
      appState.storyTimeActive = true
      Object.deliverChangeRecords launcher.observer
      expect(dummyJiraPage).toContainElement('#JST-menu-test-elm')
