class JiraStoryTime.Views.Epic extends JiraStoryTime.Utils.Observer
  constructor: (@epic) ->
    super()
    @observe @epic
    @el = $(JiraStoryTime.Utils.Templates.get('epic.html'))
    @el.addClass("epic-color-#{@epic.color}")
    @el.find('input[type=checkbox]').attr('id', "epic-#{@epic.color}")
    @el.find('label').attr('for', "epic-#{@epic.color}")
    @el.find('.epic-name').html(@epic.name)
    @el.find('input[type=checkbox]').on 'change', @epic.toggleVisibility
    @updatePoints()

  onObservedChange: (change) =>
    @updatePoints()

  updatePoints: () =>
    @el.find('.story-points').html("#{@epic.points} / #{@epic.business}")

  deconstruct: () =>
    @unobserveAll()
    @el.find('checkbox').off()
    @el.remove()
