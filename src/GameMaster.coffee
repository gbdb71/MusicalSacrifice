#= require SingletonEntity
MS = window.MusicalSacrifice

class GameMaster extends MS.SingletonEntity
  DELAY = 1000
  init:->
    @possibleLevels = ["Soccer"]
    @currentState = null
    @createdAt = Date.now()
    @started = false
    @started2 = false
    @level = null
    @levelId = null

  controlledUpdate:->
    if Date.now() - @createdAt > DELAY && !@started
      @started = true
      console.log("I SAY WE PLAY SOCCER NOW")
      @transitionToLevel("Soccer")

    if Date.now() - @createdAt > 20000 && !@started2
      @started2 = true
      console.log("I SAY WE PLAY SOCCER AGAIN")
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
      console.log("Following to level: #{@levelId}")
      @game.entityManager.setLevel(@levelId)
      @game.state.start(@level)

  transitionToLevel:(level)->
    if level
      @level = level
      @levelId = @level + Date.now()
      console.log("Moving to level: #{@levelId}")
      @game.entityManager.setLevel(@levelId)
      @game.state.start(@level)



MS.GameMaster = GameMaster
