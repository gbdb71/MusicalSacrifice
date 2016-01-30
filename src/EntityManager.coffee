#= require Entity
#= require SingletonEntity
#= require Avatar
#= require Ball
#= require GameMaster

MS = window.MusicalSacrifice

class EntityManager
  DELAY = 5000
  constructor: (@game)->
    @idCounter = 0
    @entities = {}
    @level = null
    @newLevel = null

    @game.network.on 'open', (channel, data)=>
      @sendInitForAllOwnedEntitiesToPeer(channel.peer, null)

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
    (Date.now() % 100000) + @game.network.myPeerId + @idCounter

  spawnRemoteEntity: (type, id, owner, state)->
    return if @entities[id] # I told him we already got one!
    console.info("Spawning remote #{type} #{id} #{state} for #{owner}")
    @addEntity(type, id, true, owner, state)

  spawnOwnedEntity: (type, state={})->
    if MS.entities[type].prototype instanceof MS.SingletonEntity
      if _.filter(@getEntitiesOfType(type), (entity)-> !entity.forLevel? || entity.forLevel == @level).length > 0
        console.info("Skipping spawning singleton type #{type} because prior exist")
        return

    id = @getNewId()
    console.info("Spawning owned #{type} #{id}: ", state)
    entity = @addEntity(type, id, false, @game.network.myPeerId, state)
    @broadcastInitEntity(entity)
    entity

  addEntity: (type, id, isRemote, owner, state={})=>
    entityClass = MS.entities[type] # get class from string
    e = new entityClass(@game, id, isRemote, owner)
    e.forLevel = @level
    e.type = type
    e.setState(state)
    @entities[id] = e

  removeEntitiesForPeerId: (peerId)->
    _.each(@getEntitiesForPeerId(peerId), (entity)=>
      @removeEntity(entity)
    )

  removeEntity:(entity)->
    return if !entity
    console.info("Removing entity: #{entity.type} #{entity.name}")
    @entities[entity.id].remove()
    delete @entities[entity.id]

  cleanUpOldLevel:()->
    console.info("Leaving Level")
    _.each @entities, (entity)=>
      if entity.forLevel && entity.forLevel != @level && !entity.isRemote
        @despawnEntity(entity)

  setLevel:(level)->
    @newLevel = level

  startLevel:->
    if @level != @newLevel
      @level = @newLevel
      @newLevel = null
      @game.network.broadcastToAllChannels(
        message: "joinLevel",
        level: @level
      )
      @cleanUpOldLevel()

  processIncoming:(data, remote)->
    console.debug("Received: ", data) unless data.message == "update"
    if data.message == "initEntity"
      if !data.forLevel || data.forLevel == @level
        @spawnRemoteEntity(data.type, data.id, remote.peer, data.state)
    else if data.message == "update"
      entity = @entities[data.id]
      if entity
        entity.setState(data.state)
    else if data.message == "despawn"
      entity = @entities[data.id]
      @removeEntity(entity)
    else if data.message == "grantOwnership"
      console.info("Received grant ownership message #{data}")
      entity = @entities[data.id]
      @onGrantOwnership(entity, data.newOwner)
    else if data.message == "joinLevel"
      @sendInitForAllOwnedEntitiesToPeer(remote.peer, data.level)


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
    console.info("Granting ownership of #{entity.type} to #{newOwner}")
    @broadcastGrantOwnership(entity, newOwner)
    @onGrantOwnership(entity, newOwner)

  onGrantOwnership:(entity, newOwner)->
    console.info("Been told to grant ownership of #{entity.type} #{entity.id} to #{newOwner}")
    entity.setOwned(newOwner == @game.network.myPeerId)
    entity.owner = newOwner

  despawnEntity:(entity)->
    return if !entity

    console.info("Despawning entity: #{entity.type} #{entity.name}")
    @broadcastDespawnEntity(entity)
    @removeEntity(entity)

  broadcastInitEntity:(entity)->
    @game.network.broadcastToAllChannels @getInitEntityMessage(entity)

  sendInitForAllOwnedEntitiesToPeer:(peer, level)->
    channel = @game.network.getChannelForPeerId(peer)
    _.each(@getMyEntities(), (entity)=>
      if (!entity.forLevel && !level) || entity.forLevel == level
        message = @getInitEntityMessage(entity)
        console.debug("Sending: ", message)
        channel.send message
    )

  getInitEntityMessage:(entity)->
    "message": "initEntity",
    "forLevel": entity.forLevel,
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
