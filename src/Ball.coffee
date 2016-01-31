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
    console.log('Kicking')
    @rolling = true
    @sprite.body.velocity = vector
    console.debug("Setting Ball possessor to #{null}")
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
      console.debug("Been told to set possessor to #{state.possessorId} #{@game.entityManager.entities[state.possessorId]?.owner}")
      @possessorId = state.possessorId
    @catchable = state.catchable
    if @sprite.animations.currentAnim? && @sprite.animations.currentAnim.name != state.anim
      @sprite.animations.play(state.anim)

  getState:(state)->
    x: @sprite.position.x,
    y: @sprite.position.y,
    possessorId: @possessorId
    catchable: @catchable
    anim: @sprite.animations.currentAnim?.name
    angular: @sprite.body?.angularVelocity

  remove: ->
    @sprite.kill()
    @sprite.shadow.kill()

  controlledUpdate:->
    return unless @sprite.alive
    return unless @sprite.body?

    velocity = @sprite.body.velocity

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

    if !@possessorId && @catchable
      # get all avatars and see if any are overlapping
      avatars = @game.entityManager.getEntitiesOfType("Avatar")
      _.each(avatars, (avatar)=>
        hitbox = new Phaser.Rectangle(avatar.sprite.position.x, avatar.sprite.position.y - 25, 30, 30)
        if Phaser.Rectangle.intersects(hitbox, @sprite.getBounds())
          console.debug("Setting Ball possessor to #{avatar.id} #{avatar.owner}")
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
