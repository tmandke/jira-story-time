class JiraStoryTime.Views.ApplicationMenu
  constructor: (@appState) ->
    @el = $(JiraStoryTime.Utils.Templates.get('menu.html'))
    @listEl = @el.find('#JST-menu-list')
    appState = @appState
    @appState.queryParams.forEach (param) =>
      if param.visible == true
        if param.type == 'bool'
          @listEl.find('li:last').before JiraStoryTime.Utils.Templates.get("menu_item_bool.html")
          @listEl.find('.bool-menu-item .menu-item-title').last().html(param.humanName)
          @listEl.find('.bool-menu-item input.onoffswitch-checkbox').last().attr('id', "JST-#{param.paramName}")
          @listEl.find('.bool-menu-item input.onoffswitch-checkbox').last().attr('checked', param.getParam())
          @listEl.find('.bool-menu-item input.onoffswitch-checkbox').last().attr('name', "JST-#{param.paramName}")
          @listEl.find('.bool-menu-item label.onoffswitch-label').last().attr('for', "JST-#{param.paramName}")
          @listEl.find('.bool-menu-item input.onoffswitch-checkbox').last().change(->
            appState[param.paramName] = @.checked
          )
        else if param.type == 'radio'
          @listEl.find('li:last').before JiraStoryTime.Utils.Templates.get("menu_item_radio.html")
          @listEl.find('.radio-menu-item .menu-item-title').last().html(param.humanName)
          radioParam = @listEl.find('.radio-menu-item').last()
          currVal = param.getParam()
          param.possibleValues.forEach (val) ->
            radioParam.append JiraStoryTime.Utils.Templates.get("menu_item_radio_item.html")
            cleanVal = val.replace new RegExp(' ','g') , ""
            radioParam.find('input').last().attr('id', "JST-#{param.paramName}-#{cleanVal}")
            radioParam.find('input').last().attr('name', "JST-#{param.paramName}")
            radioParam.find('input').last().attr('checked', currVal is val)
            radioParam.find('input').last().attr('value', val)
            radioParam.find('label').last().html val
            radioParam.find('label').last().attr('for', "JST-#{param.paramName}-#{cleanVal}")

          radioParam.find('input').change( ->
            appState[param.paramName] = radioParam.find("input[name=JST-#{param.paramName}]:checked").val()
          )

  deconstruct: () ->
