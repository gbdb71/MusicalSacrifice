#= require Entity

class Ball extends Entity
  ACCELERATION = 500
  MAX_SPEED = 200
  DRAG = 200

  constructor: ->
    super

    @sprite = @host.spriteGroup.create(-100,-100, 'ball')
    @possessorId = null
    @catchable = false
    @kickTime = Date.now()

    if !@isRemote
      @host.game.physics.arcade.enable(@sprite)
      @sprite.body.drag.set(DRAG, DRAG)

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

  despawn: ->
    @sprite.kill()

  controlledUpdate:->
    if @possessorId?
      possessor = @manager.entities[@possessorId]
      if possessor?
        @sprite.position.x = possessor.sprite.position.x + 10
        @sprite.position.y = possessor.sprite.position.y + 24

      moves = @host.pollController()
      if (moves.but1)
        vector = possessor.sprite.body.acceleration.clone().setMagnitude(500)
        @kick(vector)


    @catchable = @getTimeSinceKick() > 0.5

    #follow another entity

window.Ball = Ball
