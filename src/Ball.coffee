#= require SingletonEntity

class Ball extends SingletonEntity
  ACCELERATION = 500
  MAX_SPEED = 200
  DRAG = 200
  CATCH_COOLDOWN = 300
  KICK_MAGNITUDE = 400

  init:->
    @sprite = @game.entityManager.group.create(-100,-100, 'ball')
    @possessorId = null
    @catchable = false
    @kickTime = Date.now()

  onLoseOwnership:->
    @sprite.body.moves = false

  onGainOwnership:->
    if !@sprite.body?
      @game.physics.arcade.enable(@sprite)
      @sprite.body.drag.set(DRAG, DRAG)
      @sprite.body.collideWorldBounds = true
      @sprite.body.bounce.set(0.9,0.9)
    @sprite.body.moves = true

  kick:(vector)->
    @rolling = true
    @sprite.body.velocity = vector
    @possessorId = null
    @kickTime = Date.now()

  getTimeSinceKick:->
    Date.now() - @kickTime

  getSpeed:->
    @sprite.body.velocity.x**2 + @sprite.body.velocity.y**2

  setState:(state)->
    @sprite.position.x = state.x
    @sprite.position.y = state.y
    @possessorId = state.possessorId
    @catchable = state.catchable

  getState:(state)->
    x: @sprite.position.x,
    y: @sprite.position.y,
    possessorId: @possessorId
    catchable: @catchable

  remove: ->
    @sprite.kill()

  controlledUpdate:->
    super
    if @possessorId?
      possessor = @game.entityManager.entities[@possessorId]
      if possessor?
        @sprite.position.x = possessor.sprite.position.x + 10
        @sprite.position.y = possessor.sprite.position.y + 28

        moves = @game.controller.poll()
        if (moves.but1)
          vector = possessor.sprite.body.acceleration.clone().setMagnitude(KICK_MAGNITUDE)
          @kick(vector)

    else if @catchable
      # get all avatars and see if any are overlapping
      avatars = @game.entityManager.getEntitiesOfType("Avatar")
      _.each(avatars, (avatar)=>
        if Phaser.Rectangle.intersects(avatar.sprite.getBounds(), @sprite.getBounds())
          @possessorId = avatar.id
          @game.entityManager.grantOwnership(this, avatar.owner)
          @catchable = false
          return
        )

    @catchable = @getTimeSinceKick() > CATCH_COOLDOWN


window.Ball = Ball
