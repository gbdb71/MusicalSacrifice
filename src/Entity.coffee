MS = window.MusicalSacrifice

class Entity
  constructor: (@game, @id, @isRemote, @owner)->
    @lastState = {}
    @type = null
    @forLevel = null
    @caption = null
    @spawned = false
    @rate = null

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
    @caption.spawned = false
    @game.time.events.add(7000, @removeCaption, this)

  removeCaption:->
    if !!@caption
      @caption.shadow.destroy()
      @caption.destroy()
      @caption = null

  updateCaption:(x, y, offset)->
    if !!@caption
      if !@isRemote or !@caption.spawned
        @caption.x = x
        @caption.y = y+offset
        @caption.shadow.x = x+2
        @caption.shadow.y = y+offset+2
        @caption.spawned = true
      else
        blend = @game.add.tween(@caption)
        blend.to({ x: x, y: y+offset }, @rate, Phaser.Easing.Linear.None, true, 0, 0)
        blend = @game.add.tween(@caption.shadow)
        blend.to({ x: x+2, y: y+offset+2 }, @rate, Phaser.Easing.Linear.None, true, 0, 0)

MS.Entity = Entity
