class JiraStoryTime.Views.Errors extends JiraStoryTime.Utils.Observer
  constructor: (@errors) ->
    super()
    @observe @errors
    @el = $('#error-banner')
    @render()

  onObservedChange: (change) =>
    if change.object is @errors
      @render()

  render: () =>
    @el.empty()
    @errors.forEach (e) =>
      ev = $(JiraStoryTime.Utils.Templates.get('error.html'))
      ev.find('.error-message').text(e.message)
      ev.find('.possible-solution').html(e.possibleSolution)
      ev.find('.response-status').text(e.responseStatus)
      ev.find('.response-text').text(e.responseText)
      @el.append ev
    true

  deconstruct: () =>
    @unobserveAll()
