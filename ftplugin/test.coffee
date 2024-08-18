# Some Comment here....
class Example
  constructor: ->
    @value = 4

    isDeclarativeComponentType: (componentType) ->
      [vueComponent_v1, vueComponent_v2].includes(componentType) or [reactComponent_v2].includes(componentType)

    isDeclarativeComponentTypeV2: (componentType) ->
      [vueComponent_v2].includes(componentType) or [reactComponent_v2].includes(componentType)

    _isComponentTypeVueV2: (componentType) ->
      componentType is vueComponent_v2

    comment :wq
    2
    if something then
      somethig
      log.e "Something is wrong"
      log.w "This is a warning"
      log.i "This is info"
    return something iframe 
