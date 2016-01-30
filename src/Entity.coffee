class Entity
  constructor: (manager, id, isRemote, broadcastStateFn)->
    @isRemote = isRemote
    @id = id
    @lastState = {}
    @broadcastState = broadcastStateFn
    @manager = manager
    @host = manager.host
    @type = @constructor.name

  update: ->
    return if @isRemote

    @controlledUpdate()
    @updateRemotes()

  updateRemotes: ->
    newState = @getState()
    if !_.isEqual(lastState, newState)
      @broadcastState(@id, newState)
      lastState = newState

  getState: ->
    {}

  setState:(state) ->
    # override to apply received state to entity

  controlledUpdate: ->
    # override to authoratively update state

  remove: ->

window.Entity = Entity
