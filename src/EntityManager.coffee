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

  spawnRemoteEntity: (type, id, state)->
    console.log("Spawning remote #{type} #{id} #{state}")
    @addEntity(type, id, true, state)

  spawnOwnedEntity: (type, state)->
    if window[type].prototype instanceof SingletonEntity
      if @getEntitiesOfType(type).length > 0
        console.log("Skipping spawning singleton type #{type} because prior exist")
        return

    id = @getNewId()
    console.log("Spawning owned #{type} #{id} #{state}")
    entity = @addEntity(type, id, false, state)
    @broadcastInitEntity(entity)
    entity

  addEntity: (type, id, isRemote, state)=>
    entityClass = window[type] # get class from string
    e = new entityClass(this, id, isRemote, @broadcastEntityState)
    e.setState(state)
    @entities[id] = e

  removeEntitiesForPeerId: (peerId)->
    _.each(@getEntitiesForPeerId(peerId), (entity)=>
      @removeEntity(entity)
    )

  removeEntity:(entity)->
    @entities[entity.id].remove()
    delete @entities[entity.id]

  processIncoming:(data)->
    if data.message == "initEntity"
      @spawnRemoteEntity(data.type, data.id, data.state)
    else if data.message == "update"
      entity = @entities[data.id]
      if entity
        entity.setState(data.state)
    else if data.message == "despawn"
      entity = @entities[data.id]
      @removeEntity(entity)

  broadcastEntityState:(id, state)->
    @host.broadcastToAllChannels
      message: "update",
      id: id,
      state: state

  broadcastDespawnEntity:(entity)->
    @host.broadcastToAllChannels
      message: "despawn",
      id: entity.id

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
    "state": entity.getState(),

  update:->
    _.each @getMyEntities(), (entity)-> entity.update()

  getMyEntities:->
    _.filter(@entities, (entity)-> entity.isRemote == false)

  getEntitiesForPeerId:(peerId)->
    _.filter(@entities, (entity)-> entity.id.startsWith(peerId))

  getEntitiesOfType:(type)->
    _.filter(@entities, (entity)-> entity.type == type)

window.EntityManager = EntityManager
