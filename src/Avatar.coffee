#= require Entity

class Avatar extends Entity
  ACCELERATION = 600
  MAX_SPEED = 200
  DRAG = 200

  constructor: ->
    super

    @movement =
      acceleration: new Phaser.Point
      max_velocity: new Phaser.Point

    @skin = @host.generator.pick(['nigel','bruce', 'julie', 'rachel'])
    @sprite = @host.spriteGroup.create(-100,-100, @skin)
    @sprite.animations.add("down", [0, 1, 2, 1], 10, true)
    @sprite.animations.add("left", [4, 5, 6, 5], 10, true)
    @sprite.animations.add("right", [8, 9, 10, 9], 10, true)
    @sprite.animations.add("up", [12, 13, 14, 13], 10, true)
    @sprite.animations.add("idle", [1], 20, true)

    if !@isRemote
      @host.game.physics.arcade.enable(@sprite)
      @sprite.body.drag.set(DRAG, DRAG)
      @sprite.body.collideWorldBounds = true
      @sprite.body.bounce.set(0.1,0.1)

  setState:(state)->
    @sprite.position.x = state.x
    @sprite.position.y = state.y
    if @sprite.animations.currentAnim.name != state.anim
      @sprite.animations.play(state.anim)
    if state.skin && @skin != state.skin
      @skin = state.skin
      @sprite.loadTexture(@skin)

  getState:(state)->
    x: @sprite.position.x,
    y: @sprite.position.y,
    skin: @skin,
    anim: @sprite.animations.currentAnim.name

  despawn:->
    @sprite.kill()

  controlledUpdate:->
    moves = @host.pollController()

    @movement.acceleration.set(0, 0)
    @movement.max_velocity.set(MAX_SPEED, MAX_SPEED)
    if (moves.left)
      @movement.acceleration.x = -1
    if (moves.right)
      @movement.acceleration.x = 1
    if (moves.up)
      @movement.acceleration.y = -1
    if (moves.down)
      @movement.acceleration.y = 1
    @movement.acceleration.setMagnitude(ACCELERATION)
    @sprite.body.acceleration = @movement.acceleration
    if @sprite.body.velocity.getMagnitude() > MAX_SPEED
      @movement.max_velocity.setMagnitude(MAX_SPEED)
    @sprite.body.maxVelocity = @movement.max_velocity

    anim = "idle"
    if Math.abs(@sprite.body.velocity.x) > Math.abs(@sprite.body.velocity.y)
      if @sprite.body.velocity.x > 25
        anim = "right"
      else if @sprite.body.velocity.x < -25
        anim = "left"
    else
      if @sprite.body.velocity.y > 25
        anim = "down"
      else if @sprite.body.velocity.y < -25
        anim = "up"
    if @sprite.animations.currentAnim.name != anim
      @sprite.animations.play(anim)

window.Avatar = Avatar
