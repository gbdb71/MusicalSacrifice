#= require SingletonEntity
MS = window.MusicalSacrifice

class Ball extends MS.SingletonEntity
  ACCELERATION = 500
  MAX_SPEED = 200
  DRAG = 200
  CATCH_COOLDOWN = 300
  KICK_MAGNITUDE = 400

  init:->
    @sprite = @game.entityManager.group.create(-100,-100, 'ball')
    @sprite.scale.set(2, 2)
    @sprite.anchor.set(0.5, 0.5)
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
    if !@spawned
      @sprite.position.x = state.x
      @sprite.position.y = state.y
      @spawned = true
    else
      blend = @game.add.tween(@sprite)
      blend.to({ x: state.x, y: state.y }, @rate, Phaser.Easing.Linear.None, true, 0, 0)
    @blend = @game.add.tween(@sprite)
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
    return unless @sprite.alive
    if @possessorId?
      possessor = @game.entityManager.entities[@possessorId]
      if possessor?
        offset = possessor.direction.clone()
        offset.setMagnitude(15)
        @sprite.position.x = possessor.sprite.position.x + offset.x
        @sprite.position.y = possessor.sprite.position.y + offset.y - 10

        moves = @game.controller.poll()
        if (moves.button)
          vector = possessor.direction.clone().setMagnitude(KICK_MAGNITUDE)
          @kick(vector)

    else if @catchable
      # get all avatars and see if any are overlapping
      avatars = @game.entityManager.getEntitiesOfType("Avatar")
      _.each(avatars, (avatar)=>
        hitbox = new Phaser.Rectangle(avatar.sprite.position.x, avatar.sprite.position.y - 25, 30, 30)
        if Phaser.Rectangle.intersects(hitbox, @sprite.getBounds())
          @possessorId = avatar.id
          @game.entityManager.grantOwnership(this, avatar.owner)
          @catchable = false
          return
        )
    @catchable = @getTimeSinceKick() > CATCH_COOLDOWN
    super


MS.Ball = Ball
MS.entities["Ball"] = Ball
