class KillingState extends Phaser.State
  init: ->
    @game.controller.init()
    @createdAt = Date.now()

  create: ->
    pitch = @game.add.sprite(@game.world.centerX, @game.world.centerY, 'killing')
    pitch.anchor.setTo(0.5, 0.5)
    pitch.width = 800
    pitch.height = 450
    @backgroundGroup = @game.add.group()
    @playerGroup = @game.add.group()
    @game.physics.arcade.enable(@playerGroup)
    @game.entityManager.setPlayerGroup(@playerGroup)
    @game.entityManager.setBackgroundGroup(@backgroundGroup)
    @game.entityManager.startLevel()
    avatar = @game.entityManager.spawnOwnedEntity('Avatar', {x:400, y:225})
    style =
      font: "70px Courier"
      fill: "#FFFFFF"
      align: "center"
    @text = @game.add.text(400, 400, "", style)
    @text.anchor.setTo(0.5, 0.5)
    @text.alpha = 0.5

  update:->
    @playerGroup.sort('y', Phaser.Group.SORT_ASCENDING)
    @game.entityManager.update()
    @text.setText(@game.controller.buffer)
    if Date.now() - @createdAt > 30000
      gm = @game.entityManager.getEntitiesOfType("GameMaster")[0]
      gm.endLevel("Time's up!") if gm

MusicalSacrifice.KillingState = KillingState
