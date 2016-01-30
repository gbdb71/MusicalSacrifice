class Entity
  constructor: (game, isRemote, id, broadcastStateFn)->
    @isRemote = isRemote
    @id = id
    @lastState = {}
    @broadcastState = broadcastStateFn
    @game = game
    @type = @constructor.name

  update: ->
    return if @isRemote

    @controlledUpdate()
    @updateRemotes()

  updateRemotes: ->
    newState = getState()
    if !_.isEqual(lastState, newState)
      broadcastState(newState)
      lastState = newState

  getState: ->
    {}

  setState:(state) ->
    # override to apply received state to entity

  controlledUpdate: ->
    # override to authoratively update state

window.Entity = Entity
