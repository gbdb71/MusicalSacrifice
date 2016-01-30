class SoccerState extends Phaser.State
  init: ->

  create: ->
    @spriteGroup = @game.add.group()
    @game.physics.arcade.enable(@spriteGroup)
    @game.entityManager.setGroup(@spriteGroup)

    avatar = @game.entityManager.spawnOwnedEntity('Avatar', {x:400, y:225})
    @game.entityManager.spawnOwnedEntity('Ball', {x:400, y:225, possessorId: avatar.id})

  update:->
    @spriteGroup.sort('y', Phaser.Group.SORT_ASCENDING)
    @game.entityManager.update()

MusicalSacrifice.SoccerState = SoccerState
