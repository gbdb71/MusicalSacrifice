#= require Entity

class Ball extends Entity
  constructor: ->
    super

    @sprite = @host.spriteGroup.create(-100,-100, 'ball')
    @possessorId = null

    if !@isRemote
      @host.game.physics.arcade.enable(@sprite)


  setState:(state)->
    @sprite.position.x = state.x
    @sprite.position.y = state.y
    @possessorId = state.possessorId

  getState:(state)->
    x: @sprite.position.x,
    y: @sprite.position.y,
    possessorId: @possessorId

  despawn: ->
    @sprite.kill()

  controlledUpdate:->
    if @possessorId?
      possessor = @manager.entities[@possessorId]
      if possessor?
        @sprite.position.x = possessor.sprite.position.x + 10
        @sprite.position.y = possessor.sprite.position.y + 24

    #follow another entity

window.Ball = Ball
