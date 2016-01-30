#= require Entity
#= require SingletonEntity
#= require Avatar
#= require Ball

class EntityManager
  constructor: (host, hostPeerId)->
    @hostPeerId = hostPeerId
    @idCounter = 0
    @host = host
    @entities = {}

  getNewId:->
    @idCounter += 1
    @hostPeerId + @idCounter

  spawnRemoteEntity: (type, id, owner, state)->
    console.log("Spawning remote #{type} #{id} #{state} for @{owner}")
    @addEntity(type, id, true, owner, state)

  spawnOwnedEntity: (type, state)->
    if window[type].prototype instanceof SingletonEntity
      if @getEntitiesOfType(type).length > 0
        console.log("Skipping spawning singleton type #{type} because prior exist")
        return

    id = @getNewId()
    console.log("Spawning owned #{type} #{id} #{state}")
    entity = @addEntity(type, id, false, @hostPeerId, state)
    @broadcastInitEntity(entity)
    entity

  addEntity: (type, id, isRemote, owner, state)=>
    entityClass = window[type] # get class from string
    e = new entityClass(this, id, isRemote, owner)
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
    state = entity._getState()
    @host.broadcastToAllChannels
      message: "update",
      id: id,
      state: state

  broadcastDespawnEntity:(entity)->
    @host.broadcastToAllChannels
      message: "despawn",
      id: entity.id

  broadcastGrantOwnership:(entity, newOwner)->
    @host.broadcastToAllChannels
      message: "grantOwnership",
      id: entity.id,
      newOwner: newOwner

  grantOwnership:(entity, newOwner)->
    console.log("Granting ownership of #{entity.type} to #{newOwner}")
    @broadcastGrantOwnership(entity, newOwner)
    @onGrantOwnership(entity, newOwner)

  onGrantOwnership:(entity, newOwner)->
    console.log("been told to grant ownership of #{entity.type} #{entity.id} to #{newOwner}")
    entity.setOwned(newOwner == @hostPeerId)
    entity.owner = newOwner

  despawnEntity:(entity)->
    @broadcastDespawnEntity(entity)
    @removeEntity(entity)

  broadcastInitEntity:(entity)->
    @host.broadcastToAllChannels @getInitEntityMessage(entity)

  sendInitForAllOwnedEntitiesToChannel:(channel)->
    _.each(@getMyEntities(), (entity)=>
      channel.send @getInitEntityMessage(entity)
    )

  getInitEntityMessage:(entity)->
    "message": "initEntity",
    "type": entity.type
    "id": entity.id,
    "state": entity._getState(),

  update:->
    _.each @getMyEntities(), (entity)-> entity.update()

  getMyEntities:->
    _.filter(@entities, (entity)-> entity.isRemote == false)

  getEntitiesForPeerId:(peerId)->
    _.filter(@entities, (entity)-> entity.id.startsWith(peerId))

  getEntitiesOfType:(type)->
    _.filter(@entities, (entity)-> entity.type == type)

window.EntityManager = EntityManager
