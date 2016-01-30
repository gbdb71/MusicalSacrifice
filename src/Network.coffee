#= require PeerHeartbeater

MS = window.MusicalSacrifice

class Network
  HOST = 'router.kranzky.com'
  PORT = 80

  constructor:(world, user)->
    @callbacks =
      'ready': []
      'open': []
      'data': []
      'close': []
    @allPeers = [ ]
    @myPeerId = world + '_' + user
    @peer = new Peer(@myPeerId, { host: HOST, port: PORT })

    @peer.on 'open', (id)=>
      window.makePeerHeartbeater(@peer)
      console.info('Starting as peer ' + id)
      @processCallbacks('ready', null, {})
      @peer.listAllPeers (data)=>
        data = _.without(data, @myPeerId)
        data = _.filter data, (peerId)=>
          world == peerId.slice(0, -5)
        @allPeers = _.map data, (peerId) =>
          channel = @peer.connect(peerId)
          channel.on 'open', =>
            console.info('Joining peer ' + peerId)
            channel.send({ message: "arrive" })
            @processCallbacks('open', channel, {})
          channel

    @peer.on 'connection', (remote)=>
      return if world != remote.peer.slice(0, -5)
      remote.on 'data', (data)=>
        if data.message == "arrive"
          channel = @peer.connect remote.peer
          channel.on 'open', =>
            console.info('Initializing ourselves on peer ' + remote.peer)
            @allPeers.push(channel)
            @processCallbacks('open', channel, {})
        @processCallbacks('data', remote, data)
      remote.on 'close', =>
        @allPeers = _.reject @allPeers, (channel)-> channel.peer == remote.peer
        @processCallbacks('close', remote, {})

  on:(name, callback)->
    @callbacks[name].push(callback)

  processCallbacks:(name, channel, data)->
    _.each @callbacks[name], (callback)->
      callback(channel, data)

  broadcastToAllChannels:(data)->
    _.each @allPeers, (connection)->
      connection.send(data)

  getChannelForPeerId:(peerId)->
    _.find @allPeers, (channel)->
      channel.peer == peerId

MS.Network = Network
