class SoccerState extends Phaser.State
  init: ->
    @game.controller.init()
    @createdAt = Date.now()
    # to prevent most redundant ball spawns
    @ballSpawnDelaytimer = @game.generator.pick([0, 500, 1000, 1500, 2000, 2500])
    @ballSpawned = false

  create: ->
    pitch = @game.add.sprite(@game.world.centerX, @game.world.centerY, 'soccer')
    pitch.anchor.setTo(0.5, 0.5)
    pitch.width = 800
    pitch.height = 450
    @backgroundGroup = @game.add.group()
    @playerGroup = @game.add.group()
    @game.physics.arcade.enable(@playerGroup)
    @game.entityManager.setPlayerGroup(@playerGroup)
    @game.entityManager.setBackgroundGroup(@backgroundGroup)
    @game.entityManager.startLevel()
    @playerAvatar = @game.entityManager.spawnOwnedEntity('Avatar', {x:400, y:225})

    style =
      font: "70px Courier"
      fill: "#FFFFFF"
      align: "center"
    @text = @game.add.text(400, 400, "", style)
    @text.anchor.setTo(0.5, 0.5)
    @text.alpha = 0.5

    @possessors = []

  update:->
    if !@ballSpawned && (Date.now() - @createdAt > @ballSpawnDelaytimer)
      @ballSpawned = true
      @game.entityManager.spawnOwnedEntity('Ball', {x:400, y:225, possessorId: @playerAvatar.id})

    @playerGroup.sort('y', Phaser.Group.SORT_ASCENDING)
    @game.entityManager.update()
    @text.setText(@game.controller.buffer)

    # see who is dribbling the ball
    balls = @game.entityManager.getEntitiesOfType("Ball")
    return if balls.length == 0

    possessorId = balls[0].possessorId
    if possessorId not in @possessors
      @possessors.push possessorId
      console.debug("Soccer sees that #{@possessors} have had the ball")
      # check everyone has had a dribble
      if _.all(@game.entityManager.getEntitiesOfType("Avatar"), (avatar)=> avatar.id in @possessors) && @possessors.length > 1
        # game over man!
        # if we're the boss, tell the gamemaster
        # if we're not the authoritative GM then it'll get ignored
        gm = @game.entityManager.getEntitiesOfType("GameMaster")[0]
        gm.endLevel("Noice Passing!") if gm

MusicalSacrifice.SoccerState = SoccerState
