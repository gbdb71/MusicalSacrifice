class SoccerState extends Phaser.State
  init: ->
    @game.controller.init()
    @createdAt = Date.now()
    # to prevent most redundant ball spawns
    @ballSpawnDelaytimer = @game.generator.pick([0, 100, 200, 300, 400, 500])
    @ballSpawned = false
    @theBallId = null

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

    style =
      font: "20px Courier"
      fill: "#00ff44"
      align: "center"
    @status = @game.add.text(@game.world.centerX, 13, "Pass to everyone!", style)
    @status.anchor.setTo(0.5, 0.5)
    @possessors = []

  update:->
    if !@ballSpawned && (Date.now() - @createdAt > @ballSpawnDelaytimer)
      @ballSpawned = true
      @game.entityManager.spawnOwnedEntity('Ball', {x:400, y:225, possessorId: @playerAvatar.id})

    @playerGroup.sort('y', Phaser.Group.SORT_ASCENDING)
    @game.entityManager.update()
    @text.setText(@game.controller.buffer)

    # see who is dribbling the ball
    ball = @game.entityManager.getEntitiesOfType("Ball")[0]
    return if !ball

    # if a new ball has appeared on the scene we'd better clear the possessors
    if @theBallId != ball.id
      @possessors = []
    @theBallId = ball.id

    possessorId = ball.possessorId

    if Date.now() - @createdAt > 3000
      # give people a chance to read the intro
      avatar = @game.entityManager.entities[possessorId]
      if avatar
        @status.setText("#{avatar.skin} has the ball!")
      else
        @status.setText("Grab the ball!")

    if possessorId not in @possessors
      @possessors.push possessorId
      console.debug("Soccer sees that #{@possessors} have had the ball")
      # check everyone has had a dribble
      if _.all(@game.entityManager.getEntitiesOfType("Avatar"), (avatar)=> avatar.id in @possessors) && @possessors.length > 1
        # game over man!
        # if we're the boss, tell the gamemaster
        # if we're not the authoritative GM then it'll get ignored
        gm = @game.entityManager.getEntitiesOfType("GameMaster")[0]
        gm.endLevel("Everyone had a touch!\nNoice Passing!") if gm

MusicalSacrifice.SoccerState = SoccerState
