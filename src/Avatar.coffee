#= require Entity
MS = window.MusicalSacrifice

class Avatar extends MS.Entity
  ACCELERATION = 600
  MAX_SPEED = 200
  DRAG = 200

  init: ->
    @direction = new Phaser.Point(0, 1)

    @setSprite()

    if !@isRemote
      @game.physics.arcade.enable(@sprite)
      @sprite.body.drag.set(DRAG, DRAG)
      @sprite.body.collideWorldBounds = true
      @sprite.body.bounce.set(0.7,0.7)
      @sprite.body.height = 16
      @sprite.body.width = 20

  setSprite: ->
    @skin = @game.generator.pick(@game.sheets)
    @row = @game.generator.pick([0, 1])
    @col = @game.generator.pick([0, 1, 2, 3])
    @sprite = @game.entityManager.group.create(-100,-100, @skin)
    @sprite.scale.set(2, 2)
    @sprite.anchor.set(0.5, 0.9)
    @setAnimations()

  setAnimations: ->
    top = @row*48 + @col*3
    @sprite.animations.add("idle", [top + 1], 10, true)
    @sprite.animations.add("down", [top, top+1, top+2], 10, true)
    top += 12
    @sprite.animations.add("left", [top, top+1, top+2], 10, true)
    top += 12
    @sprite.animations.add("right", [top, top+1, top+2], 10, true)
    top += 12
    @sprite.animations.add("up", [top, top+1, top+2], 10, true)
    @sprite.animations.play("idle")

  setState:(state)->
    if !@spawned
      @sprite.position.x = state.x
      @sprite.position.y = state.y
      @spawned = true
    else
      blend = @game.add.tween(@sprite)
      blend.to({ x: state.x, y: state.y }, @rate, Phaser.Easing.Linear.None, true, 0, 0)
    if @sprite.animations.currentAnim? && @sprite.animations.currentAnim.name != state.anim
      @sprite.animations.play(state.anim)
    if state.skin && (@skin != state.skin[0] || @row != state.skin[1] || @col != state.skin[2])
      @skin = state.skin[0]
      @row = state.skin[1]
      @col = state.skin[2]
      @sprite.loadTexture(@skin)
      @setAnimations()
    if state.message && @caption?.message != state.message
      @setCaption(state.message)
    @updateCaption(state.x, state.y, 15-@sprite.height)

  getState:(state)->
    x: @sprite.position.x,
    y: @sprite.position.y,
    skin: [@skin, @row, @col],
    anim: @sprite.animations.currentAnim.name
    message: @caption?.message

  remove:->
    @sprite.kill()

  controlledUpdate:->
    return unless @sprite.alive

    @updateCaption(@sprite.position.x, @sprite.position.y, 15-@sprite.height)

    if @game.controller.message.length > 0
      @setCaption(@game.controller.message)
      @game.controller.message = ""

    moves = @game.controller.poll()

    @direction.set(0, 0)
    if (moves.left)
      @direction.x = -1
    if (moves.right)
      @direction.x = 1
    if (moves.up)
      @direction.y = -1
    if (moves.down)
      @direction.y = 1
    acceleration = @direction.clone()
    acceleration.setMagnitude(ACCELERATION)
    @sprite.body.acceleration = acceleration
    if @direction.isZero()
      @direction.y = 1
    max_velocity = new Phaser.Point(MAX_SPEED, MAX_SPEED)
    if @sprite.body.velocity.getMagnitude() > MAX_SPEED
      max_velocity.setMagnitude(MAX_SPEED)
    @sprite.body.maxVelocity = max_velocity

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

MS.Avatar = Avatar
MS.entities["Avatar"] = Avatar
