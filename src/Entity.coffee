class Entity
  constructor: (host, id, isRemote, broadcastStateFn)->
    @isRemote = isRemote
    @id = id
    @lastState = {}
    @broadcastState = broadcastStateFn
    @host = host
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

  despawn: ->

window.Entity = Entity
