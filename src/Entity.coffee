MS = window.MusicalSacrifice

class Entity
  constructor: (@game, @id, @isRemote, @owner)->
    @lastState = {}
    @type = null
    @forLevel = null
    @caption = null

    @init()

    if !@isRemote
      @onGainOwnership()

  update:(send)->
    return if @isRemote

    @controlledUpdate()
    @updateRemotes() if send

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
        console.debug("We gained ownership of #{@type} #{@id}")
        @onGainOwnership()
      else
        console.debug("We lost ownership of #{@type} #{@id}")
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

  setCaption:(message)->
    style = {
      font: "18px Arial",
      fill: '#FFFF00',
      align: "center"
    }
    shadow_style = {
      font: "18px Arial",
      fill: "#000000",
      align: "center"
    }
    @removeCaption()
    shadow = @game.add.text(0, 0, message, shadow_style)
    @caption = @game.add.text(0, 0, message, style)
    @caption.anchor.setTo(0.5, 1.0);
    @caption.shadow = shadow
    @caption.shadow.anchor.setTo(0.5, 1.0);
    @caption.message = message
    @game.time.events.add(5000, @removeCaption, this)

  removeCaption:->
    if !!@caption
      @caption.shadow.destroy()
      @caption.destroy()
      @caption = null

  updateCaption:(sprite, offset)->
    if !!@caption
      @caption.x = sprite.position.x
      @caption.y = sprite.position.y + offset
      @caption.shadow.x = @caption.x + 2
      @caption.shadow.y = @caption.y + 2

MS.Entity = Entity
