#= require Entity

class EntityManager
  constructor: (game, hostPeerId)->
    @hostPeerId = hostPeerId
    @idCounter = 1
    @game = game
    @entities = {}

  getNewId:->
    @hostPeerId + @idCounter
    @idCounter += 1

  spawnRemoteEntity: (type, id, state)->
    addEntity(type, id, false, state)

  spawnOwnedEntity: (type, state)->
    entity = addEntity(type, getNewId(), true, state)
    broadcastInitEntity(entity)

  addEntity: (type, id, remote, state)->
    entityClass = new window[type] # get class from string
    e = entityClass(@game, id, remote, @broadcastEntityState)
    e.setState(state)
    @entities[id] = e

  processIncoming:(data)->
    if data.message == "initEntity"
      spawnRemoteEntity(data.type, data.id, data.state)
    else if data.message == "update"
      @entities[data.id].setState(data.state)


  broadcastEntityState:(id, state)->
    @game.broadcastToAllChannels({
      "message": "update",
      "id": "id",
      "state": state
    })

  broadcastInitialOwnedEntities:->
    _.each(getMyEntities(), (entity)->
      @broadcastInitEntity(entity)
    )

  broadcastInitEntity:(entity)->
    @game.broadcastToAllChannels({
      "message": "initEntity",
      "type": entity.type
      "id": entity.id,
      "state": state,
    })


  getMyEntities:->
    _filter(@entities, (entity)-> entity.remote == false)

window.EntityManager = entityManager
