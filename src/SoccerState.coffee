class SoccerState extends Phaser.State
  init: ->
    #@game.entityManager.startState()

  create: ->
    pitch = @game.add.sprite(@game.world.centerX, @game.world.centerY, 'soccer')
    pitch.anchor.setTo(0.5, 0.5)
    pitch.width = 800
    pitch.height = 450
    @spriteGroup = @game.add.group()
    @game.physics.arcade.enable(@spriteGroup)
    @game.entityManager.setGroup(@spriteGroup)
    avatar = @game.entityManager.spawnOwnedEntity('Avatar', {x:400, y:225})
    @game.entityManager.spawnOwnedEntity('Ball', {x:400, y:225, possessorId: avatar.id})

  update:->
    @game.entityManager.update()

  shutdown:->
    #@game.entityManager.endState()

MusicalSacrifice.SoccerState = SoccerState
