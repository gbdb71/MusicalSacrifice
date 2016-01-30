#= require PeerHeartbeater

MS = window.MusicalSacrifice

class Network
  constructor:->
    @callbacks =
      'ready': []
      'open': []
      'data': []
      'close': []
    @allPeers = [ ]
    @myPeerId = null
    @peer = new Peer({ host: 'router.kranzky.com', port: 80, config: { 'iceServers': [] }, debug: 0 })
    # @peer = new Peer({ host: 'localhost', port: 9000, config: { 'iceServers': [] }, debug: 0 })


    @peer.on 'open', (id)=>
      window.makePeerHeartbeater(@peer)
      console.info('Starting as peer ' + id)
      @myPeerId = id
      @processCallbacks('ready', null, {})
      @peer.listAllPeers (data)=>
        data = _.without(data, @myPeerId)
        @allPeers = _.map data, (peerId) =>
          channel = @peer.connect(peerId)
          channel.on 'open', =>
            console.info('Joining peer ' + peerId)
            channel.send({ message: "arrive" })
            @processCallbacks('open', channel, {})
          channel

    @peer.on 'connection', (remote)=>
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
