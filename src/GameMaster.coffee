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
    @levelId = null

  controlledUpdate:->
    if Date.now() - @createdAt > DELAY && !@started
      @started = true
      console.log("I SAY WE PLAY SOCCER NOW")
      @transitionToLevel("Soccer")

    super

  onGainOwnership: ->
    console.log("I AM THE GAME MASTER")

  getState:->
    level: @level
    levelId: @levelId

  setState:(state)->
    @level = state.level
    oldLevelId = @levelId
    @levelId = state.levelId
    if oldLevelId != @levelId
      @followToLevel()

  followToLevel:->
    if @level
      console.info("Following to level: #{@levelId}")
      @game.entityManager.setLevel(@levelId)
      @game.state.start(@level)

  transitionToLevel:(level)->
    if level
      @level = level
      @levelId = @level + Date.now()
      console.info("Moving to level: #{@levelId}")
      @game.entityManager.setLevel(@levelId)
      @game.state.start(@level)



MS.GameMaster = GameMaster
MS.entities["GameMaster"] = GameMaster
