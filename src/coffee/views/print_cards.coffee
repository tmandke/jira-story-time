class JiraStoryTime.Views.PrintCards
  constructor: (@application_state, @baseElem, @backlog) ->
    @el = $(JiraStoryTime.Utils.Templates.get('print_cards/print_cards.html'))
    @el.find('span.close').on 'click', () =>
      @application_state.printCards = false
    @el.find('span.print').on 'click', () =>
      @print()
    @renderSelectable()


  renderSelectable: () =>
    issuesList = $.map(@backlog.issues, (issue) =>
      issue
    ).sort((issue) ->
      issue.rank
    ).map((issue) ->
      selectableIssue = $(JiraStoryTime.Utils.Templates.get('print_cards/selectable_issue.html'))
      imageUrl = chrome.extension.getURL("/#{issue.type}.svg")
      selectableIssue.find('.issue-image').css('background-image', "url(#{imageUrl})")
      selectableIssue.addClass issue.type
      selectableIssue.find('label').attr('for', "issue-#{issue.id}")
      selectableIssue.find('input').attr('id', "issue-#{issue.id}")
      selectableIssue.find('input').attr('value', issue.id)
      selectableIssue.find('.issue-key').html(issue.key)
      selectableIssue.find('.issue-summary').html(issue.summary)
      selectableIssue.find('.issue-points').html(issue.points)
      selectableIssue.find('.issue-business').html(issue.business)
      selectableIssue.find('.issue-description').html(issue.description)
      selectableIssue
    )
    @el.find('.card-selectors').append(issuesList)

  print: () =>
    @baseElem.children().addClass('hide-me')
    @printableCards = $('<div id="printable-cards"></div>')
    @baseElem.append(@printableCards)
    @el.find('input[checked]').map((i, elem) =>
      @printableCards.append($(elem).parent().parent())
    )
    window.print()
    @printableCards.remove()
    delete @printableCards
    @baseElem.children().removeClass('hide-me')
    @application_state.printCards = false

  deconstruct: () =>
    @baseElem.children().removeClass('hide-me')
    if @printableCards?
      @printableCards.remove()
      delete @printableCards
    @el.remove()
