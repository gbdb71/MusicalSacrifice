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
    @sprite.scale.set(1.5, 1.5)
    @sprite.anchor.set(0.5, 0.5)
    @sprite.shadow = @game.entityManager.background.create(-100,-100, 'shadow')
    @sprite.shadow.scale.set(1.5, 1.5)
    @sprite.shadow.anchor.set(0.5, 0.5)

    @possessorId = null
    @catchable = false
    @kickTime = Date.now()
    @sprite.animations.add("idle", [6], 20, true)
    @sprite.animations.add("up", [6, 0, 1, 2, 3, 4, 5], 20, true)
    @sprite.animations.add("down", [6, 5, 4, 3, 2, 1, 0], 20, true)
    @sprite.animations.play("idle")

  onLoseOwnership:->
    if !!@sprite.body?
      @sprite.body = null

  onGainOwnership:->
    if !@sprite.body?
      @game.physics.arcade.enable(@sprite)
      @sprite.body.drag.set(DRAG, DRAG)
      @sprite.body.collideWorldBounds = true
      @sprite.body.bounce.set(0.9,0.9)

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
    velocity = @sprite.body.velocity
    if @possessorId?
      possessor = @game.entityManager.entities[@possessorId]
      if possessor?
        velocity = possessor.sprite.body.velocity
        offset = possessor.direction.clone()
        offset.setMagnitude(15)
        @sprite.position.x = possessor.sprite.position.x + offset.x * 2
        @sprite.position.y = possessor.sprite.position.y + offset.y - 4
        if offset.y < 0
          @sprite.position.y -= 7
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
    @sprite.body.angularVelocity = velocity.x * 7
    anim = "idle"
    if velocity.y > 10
      @sprite.body.angularVelocity = 0
      @sprite.angle *= 0.9
      anim = "up"
    else if velocity.y < -10
      @sprite.body.angularVelocity = 0
      @sprite.angle *= 0.9
      anim = "down"
    if @sprite.animations.currentAnim.name != anim
      @sprite.animations.play(anim)
    @sprite.shadow.position.x = @sprite.position.x
    @sprite.shadow.position.y = @sprite.position.y + 6
    super

MS.Ball = Ball
MS.entities["Ball"] = Ball
