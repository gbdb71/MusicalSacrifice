#= require Entity
MS = window.MusicalSacrifice

class SingletonEntity extends MS.Entity

  controlledUpdate:()->
    elderDupes = _.filter(
      @game.entityManager.getEntitiesOfType(@type), (dupe)=>
        dupe.id < @id && dupe.forLevel == @forLevel
    )

    # if there are any entities of the same type that are elder than us
    if elderDupes.length > 0
      # despawn ourselves
      console.debug("#{@type} destroying itself as it's not the best singleton")
      @game.entityManager.despawnEntity(@)

MS.SingletonEntity = SingletonEntity
