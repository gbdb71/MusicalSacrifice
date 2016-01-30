#= require Entity
#= require SingletonEntity
#= require Avatar
#= require Ball
#= require GameMaster

MS = window.MusicalSacrifice

class EntityManager
  DELAY = 5000
  constructor: (@game)->
    # TBD: hook up game.network.on...
    # @sendInitForAllOwnedEntitiesToChannel
    # @processIncoming
    # @despawnEntitiesForPeerId
    @idCounter = 0
    @entities = {}

    @game.network.on 'open', (channel, data)=>
      @sendInitForAllOwnedEntitiesToChannel(channel)

    @game.network.on 'close', (channel, data)=>
      @removeEntitiesForPeerId(channel.peer)

    @game.network.on 'data', (channel, data)=>
      @processIncoming(data, channel)

    window.setTimeout =>
      @spawnOwnedEntity("GameMaster")
    , DELAY

  setGroup: (@group)->

  getNewId:->
    @idCounter += 1
    Date.now() + '' + @idCounter

  spawnRemoteEntity: (type, id, owner, state)->
    console.log("Spawning remote #{type} #{id} #{state} for @{owner}")
    @addEntity(type, id, true, owner, state)

  spawnOwnedEntity: (type, state={})->
    if MS[type].prototype instanceof MS.SingletonEntity
      if @getEntitiesOfType(type).length > 0
        console.log("Skipping spawning singleton type #{type} because prior exist")
        return

    id = @getNewId()
    console.log("Spawning owned #{type} #{id} #{state}")
    entity = @addEntity(type, id, false, @game.network.myPeerId, state)
    @broadcastInitEntity(entity)
    entity

  addEntity: (type, id, isRemote, owner, state={})=>
    entityClass = MS[type] # get class from string
    e = new entityClass(@game, id, isRemote, owner)
    e.setState(state)
    @entities[id] = e

  removeEntitiesForPeerId: (peerId)->
    _.each(@getEntitiesForPeerId(peerId), (entity)=>
      @removeEntity(entity)
    )

  removeEntity:(entity)->
    @entities[entity.id].remove()
    delete @entities[entity.id]

  processIncoming:(data, remote)->
    if data.message == "initEntity"
      @spawnRemoteEntity(data.type, data.id, remote.peer, data.state)
    else if data.message == "update"
      entity = @entities[data.id]
      if entity
        entity.setState(data.state)
    else if data.message == "despawn"
      entity = @entities[data.id]
      @removeEntity(entity)
    else if data.message == "grantOwnership"
      console.log("Received grant ownership message #{data}")
      entity = @entities[data.id]
      @onGrantOwnership(entity, data.newOwner)

  broadcastEntityState:(entity)->
    id = entity.id
    state = entity.getState()
    @game.network.broadcastToAllChannels
      message: "update",
      id: id,
      state: state

  broadcastDespawnEntity:(entity)->
    @game.network.broadcastToAllChannels
      message: "despawn",
      id: entity.id

  broadcastGrantOwnership:(entity, newOwner)->
    @game.network.broadcastToAllChannels
      message: "grantOwnership",
      id: entity.id,
      newOwner: newOwner

  grantOwnership:(entity, newOwner)->
    console.log("Granting ownership of #{entity.type} to #{newOwner}")
    @broadcastGrantOwnership(entity, newOwner)
    @onGrantOwnership(entity, newOwner)

  onGrantOwnership:(entity, newOwner)->
    console.log("been told to grant ownership of #{entity.type} #{entity.id} to #{newOwner}")
    entity.setOwned(newOwner == @game.network.myPeerId)
    entity.owner = newOwner

  despawnEntity:(entity)->
    @broadcastDespawnEntity(entity)
    @removeEntity(entity)

  broadcastInitEntity:(entity)->
    @game.network.broadcastToAllChannels @getInitEntityMessage(entity)

  sendInitForAllOwnedEntitiesToChannel:(channel)->
    _.each(@getMyEntities(), (entity)=>
      channel.send @getInitEntityMessage(entity)
    )

  getInitEntityMessage:(entity)->
    "message": "initEntity",
    "type": entity.type
    "id": entity.id,
    "state": entity.getState(),

  update:->
    _.each @getMyEntities(), (entity)-> entity.update()

  getMyEntities:->
    _.filter(@entities, (entity)-> entity.isRemote == false)

  getEntitiesForPeerId:(peerId)->
    _.filter(@entities, (entity)-> entity.owner == peerId)

  getEntitiesOfType:(type)->
    _.filter(@entities, (entity)-> entity.type == type)

MS.EntityManager = EntityManager
