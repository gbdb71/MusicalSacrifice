#= require Entity
#= require Avatar
#= require Ball

MS = window.MusicalSacrifice

class EntityManager
  constructor: (@game)->
    # TBD: hook up game.network.on...
    # @sendInitForAllOwnedEntitiesToChannel
    # @processIncoming
    # @despawnEntitiesForPeerId
    @idCounter = 0
    @entities = {}

  setGroup: (@group)->

  getNewId:->
    @idCounter += 1
    @game.network.myPeerId + @idCounter

  spawnRemoteEntity: (type, id, state)->
    console.log("Spawning remote #{type} #{id} #{state}")
    @addEntity(type, id, true, state)

  spawnOwnedEntity: (type, state)->
    id = @getNewId()
    console.log("Spawning owned #{type} #{id} #{state}")
    entity = @addEntity(type, id, false, state)
    @broadcastInitEntity(entity)
    entity

  addEntity: (type, id, isRemote, state)=>
    entityClass = window[type] # get class from string
    e = new entityClass(@game, @group, id, isRemote, @broadcastEntityState)
    e.setState(state)
    @entities[id] = e

  despawnEntitiesForPeerId: (peerId)->
    _.each(@getEntitiesForPeerId(peerId), (entity)=>
      entity.despawn()
      delete @entities[entity.id]
    )

  processIncoming:(data)->
    if data.message == "initEntity"
      @spawnRemoteEntity(data.type, data.id, data.state)
    else if data.message == "update"
      entity = @entities[data.id]
      if entity
        entity.setState(data.state)

  broadcastEntityState:(id, state)->
    @game.network.broadcastToAllChannels({
      "message": "update",
      "id": id,
      "state": state
    })

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
    _.filter(@entities, (entity)-> entity.id.startsWith(peerId))


MS.EntityManager = EntityManager
