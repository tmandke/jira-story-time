afterEach ->
  fields = getJSONFixture('fields.json')
  JiraStoryTime.Models.Story._initFieldIds(fields)
