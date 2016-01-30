#= require SingletonEntity
MS = window.MusicalSacrifice

class GameMaster extends MS.SingletonEntity
  DELAY = 1000
  init:->
    @possibleLevels = ["Soccer"]
    @currentState = null
    @createdAt = Date.now()
    @started = false
    @level = null

  controlledUpdate:->
    if Date.now() - @createdAt > DELAY && !@started
      @started = true
      console.log("I SAY WE PLAY SOCCER NOW")
      @level = "Soccer"
      @transitionLevelIfRequired()
    super

  onGainOwnership: ->
    console.log("I AM THE GAME MASTER")

  getState:->
    level: @level

  setState:(state)->
    @level = state.level
    @transitionLevelIfRequired()

  transitionLevelIfRequired:->
    if @level? && @game.state.current != @level
      @game.state.start(@level)



MS.GameMaster = GameMaster
