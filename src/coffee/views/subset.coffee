class JiraStoryTime.Views.Subset extends JiraStoryTime.Utils.Observer
  constructor: (@subset) ->
    super()
    @observe @subset
    @el = $(JiraStoryTime.Utils.Templates.get('subset.html'))
    @el.addClass("subset-color-#{@subset.color}")
    @el.find('input[type=checkbox]').attr('id', "subset-#{@subset.subsetVar}-#{@subset.color}")
    @el.find('label').attr('for', "subset-#{@subset.subsetVar}-#{@subset.color}")
    @el.find('.subset-name').html(@subset.name)
    @el.find('input[type=checkbox]').on 'change', @subset.toggleVisibility
    @updatePoints()

  onObservedChange: (change) =>
    @updatePoints()

  updatePoints: () =>
    @el.find('.story-points').html("#{@subset.points} / #{@subset.business}")

  deconstruct: () =>
    @unobserveAll()
    @el.find('checkbox').off()
    @el.remove()
