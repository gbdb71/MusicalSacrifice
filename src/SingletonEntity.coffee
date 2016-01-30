#= require Entity

class SingletonEntity extends Entity

  controlledUpdate:()->
    elderDupes = _.filter(
      @game.entityManager.getEntitiesOfType(@type), (dupe)=>
        dupe.id < @id
    )

    # if there are any entities of the same type that are elder than us
    if elderDupes.length > 0
      # despawn ourselves
      console.log("#{@type} destroying itself as it's not the best singleton")
      @game.entityManager.despawnEntity(@)

window.SingletonEntity = SingletonEntity
