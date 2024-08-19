define [
  'views/view'
  'services/browser_service'
  'mediator'
 ], (
  View
  browserService
  mediator
 ) ->



# Some Comment here....
class Example
  constructor: ->
    @value = 4

    isDeclarativeComponentType: (componentType) ->
      [vueComponent_v1, vueComponent_v2].includes(componentType) or [reactComponent_v2].includes(componentType)

    isDeclarativeComponentTypeV2: (componentType) ->
      [vueComponent_v2].includes(componentType) or [reactComponent_v2].includes(componentType)

    _isComponentTypeVueV2: (componentType) =>
      componentType is "vueComponent_v2"


    switch action
      when 'open-url'

    comment :wq
    2
    if something then
      somethig
      log.e "Something is wrong"
      log.w "This is a warning"
      log.i "This is info"
    return something iframe 
