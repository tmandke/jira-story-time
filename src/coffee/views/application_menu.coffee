class JiraStoryTime.Views.ApplicationMenu
  constructor: (@menuActions) ->
    @el = $(JiraStoryTime.Utils.Templates.get('menu.html'))
    @listEl = @el.find('#JST-menu-list')
    $.map(@menuActions, (action, k) =>
      if action.param.type == 'bool'
        @listEl.append JiraStoryTime.Utils.Templates.get("menu_item_bool.html")
        @listEl.find('.menu-item-title').last().html(action.param.humanName)
        @listEl.find('input.onoffswitch-checkbox').last().attr('id', "JST-#{action.param.paramName}")
        @listEl.find('input.onoffswitch-checkbox').last().attr('checked', action.param.getParam())
        @listEl.find('input.onoffswitch-checkbox').last().attr('name', "JST-#{action.param.paramName}")
        @listEl.find('label.onoffswitch-label').last().attr('for', "JST-#{action.param.paramName}")
        @listEl.find('input.onoffswitch-checkbox').last().change(->
          action.onChange(@checked)
        )
      else if action.param.type == 'radio'
        @listEl.append JiraStoryTime.Utils.Templates.get("menu_item_radio.html")
        @listEl.find('.menu-item-title').last().html(action.param.humanName)
        radioParam = @listEl.find('.radio-menu-item').last()
        currVal = action.param.getParam()
        action.param.possibleValues.forEach (val) ->
          radioParam.append JiraStoryTime.Utils.Templates.get("menu_item_radio_item.html")
          cleanVal = val.replace new RegExp(' ','g') , ""
          radioParam.find('input').last().attr('id', "JST-#{action.param.paramName}-#{cleanVal}")
          radioParam.find('input').last().attr('name', "JST-#{action.param.paramName}")
          radioParam.find('input').last().attr('checked', currVal is val)
          radioParam.find('input').last().attr('value', val)
          radioParam.find('label').last().html val
          radioParam.find('label').last().attr('for', "JST-#{action.param.paramName}-#{cleanVal}")

        radioParam.find('input').change( ->
          action.onChange(radioParam.find("input[name=JST-#{action.param.paramName}]:checked").val())
        )
      else if action.param.type == 'click'
        @listEl.append JiraStoryTime.Utils.Templates.get("menu_item_click.html")
        @listEl.find('.menu-item-title').last().html(action.param.humanName)
        clickParam = @listEl.find('.click-menu-item').last()
        clickParam.on 'click', action.onChange
    )

  deconstruct: () ->
