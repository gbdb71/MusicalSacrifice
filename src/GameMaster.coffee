#= require SingletonEntity
MS = window.MusicalSacrifice

class GameMaster extends MS.SingletonEntity
  DELAY = 3000
  init:->
    @possibleLevels = ["Yorick"]
    @currentState = null
    @lastMove = Date.now()
    @level = 'Lobby'
    @levelId = null
    @nextLevel = @game.generator.pick(@possibleLevels)
    @intermissionMessage = null

  controlledUpdate:->
    # move out of the lobby after a time
    if (!@level || @level == "Lobby") && Date.now() - @lastMove > DELAY
      @chooseRandomLevel()
    super

  chooseRandomLevel:->
    console.log("I SAY WE PLAY #{@nextLevel} NOW")
    @transitionToLevel(@nextLevel)

  endLevel:(intermissionMessage)->
    return if @isRemote
    @nextLevel = @game.generator.pick(@possibleLevels)
    @transitionToLevel("Lobby")
    @intermissionMessage = intermissionMessage

  onGainOwnership: ->
    console.log("I AM THE GAME MASTER")

  getState:->
    level: @level
    levelId: @levelId
    msg: @intermissionMessage

  setState:(state)->
    @level = state.level
    oldLevelId = @levelId
    @levelId = state.levelId
    @intermissionMessage = state.msg
    if oldLevelId != @levelId
      @followToLevel()

  followToLevel:->
    if @level
      console.info("Following to level: #{@levelId}")
      @game.entityManager.setLevel(@levelId)
      @game.state.start(@level)

  transitionToLevel:(level)->
    if level
      @intermissionMessage = null
      @level = level
      if @level != "Lobby"
        @levelId = @level + Date.now()
      else
        @levelId = null
      @lastMove = Date.now()
      console.info("Moving to level: #{@levelId || @level}")
      @game.entityManager.setLevel(@levelId)
      @game.state.start(@level)

MS.GameMaster = GameMaster
MS.entities["GameMaster"] = GameMaster
