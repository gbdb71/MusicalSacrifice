#= require Entity

class SingletonEntity extends Entity
  constructor: ->
    super

  controlledUpdate:()->
    elderDupes = _.filter(
      @manager.getEntitiesOfType(@type), (dupe)=>
        dupe.id < @id
    )

    # if there are any entities of the same type that are elder than us
    if elderDupes.length > 0
      # despawn ourselves
      console.log("#{@type} destroying itself as it's not the best singleton")
      @manager.despawnEntity(@)

window.SingletonEntity = SingletonEntity
