MS = window.MusicalSacrifice

class Entity
  constructor: (@game, @id, @isRemote, @owner)->
    @lastState = {}

    @type = @constructor.name
    @forLevel = null

    @init()

    if !@isRemote
      @onGainOwnership()

  update: ->
    return if @isRemote

    @controlledUpdate()
    @updateRemotes()

  updateRemotes: ->
    newState = @getState()
    if !_.isEqual(@lastState, newState)
      @game.entityManager.broadcastEntityState(@)
      @lastState = newState

  setOwned:(owned)->
    # if these are equal then ownership has changed
    if owned == @isRemote
      @isRemote = !owned
      if owned
        console.log("We gained ownership of #{@type} #{@id}")
        @onGainOwnership()
      else
        console.log("We lost ownership of #{@type} #{@id}")
        @onLoseOwnership()

  getState: ->
    # override to return state to sync

  setState:(state) ->
    # override to apply received state to entity

  controlledUpdate: ->
    # override to authoratively update state

  remove: ->

  init: ->

  onGainOwnership: ->

  onLoseOwnership: ->


MS.Entity = Entity
