describe 'ApplicationLauncher', ->
  dummyJiraPage = null
  launcher = null
  appState = null
  beforeEach ->
    resetQueryParams()
    loadFixtures('dummy_jira_page.html')
    dummyJiraPage = $('#dummy-jira-page')
    appState = new JiraStoryTime.Models.ApplicationState
    launcher = new JiraStoryTime.Views.ApplicationLauncher(dummyJiraPage, appState)

  it 'adds a StoryTime button to the "ghx-modes"', ->
    expect(dummyJiraPage.find('#ghx-modes').find('#story-toggle')[0]).toBeDefined()

  it '"#story-toggle" click should make storyTimeActive to true', ->
    dummyJiraPage.find('#ghx-modes').find('#story-toggle').click()
    expect(appState.storyTimeActive).toBe true
