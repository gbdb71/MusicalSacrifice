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

    @angular = 0
    @angle = 0
    @anim = "idle"
    @possessorId = null
    @catchable = false
    @kickTime = Date.now()
    @sprite.animations.add("idle", [6], 20, true)
    @sprite.animations.add("roll", [6, 0, 1, 2, 3, 4, 5], 20, true)
    @sprite.animations.play("idle")

    @game.physics.arcade.enable(@sprite)
    if !@isRemote
      @onGainOwnership()

  onLoseOwnership:->
    @sprite.body.drag.set(0, 0)
    @sprite.body.collideWorldBounds = false
    @sprite.body.bounce.set(0, 0)
    @sprite.rotation = 0 if isNaN(@sprite.rotation)

  onGainOwnership:->
    @sprite.body.drag.set(DRAG, DRAG)
    @sprite.body.collideWorldBounds = true
    @sprite.body.bounce.set(0.9, 0.9)
    @sprite.rotation = 0 if isNaN(@sprite.rotation)

  kick:(vector)->
    @rolling = true
    @sprite.body.velocity = vector
    @possessorId = null
    @kickTime = Date.now()

  getTimeSinceKick:->
    Date.now() - @kickTime

  setState:(state)->
    if !@spawned
      @sprite.position.x = state.x
      @sprite.position.y = state.y
      @sprite.shadow.position.x = @sprite.position.x
      @sprite.shadow.position.y = @sprite.position.y + 6
      @spawned = true
    else
      blend = @game.add.tween(@sprite)
      blend.to({ x: state.x, y: state.y }, @rate, Phaser.Easing.Linear.None, true, 0, 0)
      blend = @game.add.tween(@sprite.shadow)
      blend.to({ x: state.x, y: state.y + 6 }, @rate, Phaser.Easing.Linear.None, true, 0, 0)
    if @possessorId != state.possessorId
      @possessorId = state.possessorId
    @catchable = state.catchable
    @anim = state.anim
    @angular = state.angular
    @angle = state.angle
    if @sprite.body?
      @sprite.animations.play(@anim)
      @sprite.body.angularVelocity = @angular
      if @angular == 0
        @sprite.angle = @angle
      @sprite.rotation = 0 if isNaN(@sprite.rotation)

  getState:->
    if @sprite.body?
      @sprite.animations.play(@anim)
      @sprite.body.angularVelocity = @angular
      if @angular == 0
        @sprite.angle = @angle
      @sprite.rotation = 0 if isNaN(@sprite.rotation)
    x: @sprite.position.x,
    y: @sprite.position.y,
    possessorId: @possessorId
    catchable: @catchable
    anim: @anim
    angular: @angular
    angle: @angle

  remove: ->
    @sprite.kill()
    @sprite.shadow.kill()

  controlledUpdate:->
    return unless @sprite.alive
    return unless @sprite.body?

    velocity = @sprite.body.velocity
    @sprite.rotation = 0 if isNaN(@sprite.rotation)

    if @possessorId?
      possessor = @game.entityManager.entities[@possessorId]
      if possessor? && possessor.sprite.body?
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

    @catchable = @getTimeSinceKick() > CATCH_COOLDOWN
    @sprite.shadow.position.x = @sprite.position.x
    @sprite.shadow.position.y = @sprite.position.y + 6

    @anim = "idle"
    if velocity.y > 10
      @anim = "roll"
      @angular = 0
      if velocity.x > 100
        @angle = -45
      else if velocity.x < -100
        @angle = 45
      else
        @angle = 0
    else if velocity.y < -10
      @anim = "roll"
      @angular = 0
      if velocity.x > 100
        @angle = -135
      else if velocity.x < -100
        @angle = 135
      else
        @angle = 180
    else
      @angular = velocity.x * 7
      @angle = 0
      @angle = @sprite.angle
      if Math.abs(@angular) < 10
        @angular = 0
        @angle *= 0.4

    if !@possessorId && @catchable
      # get all avatars and see if any are overlapping
      avatars = @game.entityManager.getEntitiesOfType("Avatar")
      _.each(avatars, (avatar)=>
        offset = avatar.direction.clone()
        centre = new Phaser.Point
        centre.x = avatar.sprite.position.x + offset.x * 2 - 4
        centre.y = avatar.sprite.position.y + offset.y - 6
        if offset.y < 0
          centre.y -= 7
        zoneOfInfluence = new Phaser.Rectangle(centre.x, centre.y, 12, 12)
        if Phaser.Rectangle.intersects(zoneOfInfluence, @sprite.getBounds())
          @possessorId = avatar.id
          @catchable = false
          # give the ball away if need be
          if @game.network.myPeerId != avatar.owner
            @game.entityManager.grantOwnership(this, avatar.owner)
          # send an extra update to ensure the possession message is there
          @updateRemotes()
          return
        )
    super

MS.Ball = Ball
MS.entities["Ball"] = Ball
