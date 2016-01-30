MS = window.MusicalSacrifice

class Network
  constructor:->
    @allPeers = [ ]
    @myPeerId = null
    @peer = new Peer({ host: 'router.kranzky.com', port: 80, config: { 'iceServers': [] }, debug: 0 })
    #@peer = new Peer({ host: 'localhost', port: 9000, config: { 'iceServers': [] }, debug: 0 })

    @peer.on 'open', (id)=>
      console.info('Starting as peer ' + id)
      @myPeerId = id
      @peer.listAllPeers (data)=>
        data = _.without(data, @myPeerId)
        @allPeers = _.map data, (peerId) =>
          channel = @peer.connect(peerId)
          channel.on 'open', =>
            console.info('Joining peer ' + peerId)
            channel.send({ message: "arrive" })
          channel

    @peer.on 'connection', (remote)=>
      remote.on 'data', (data)=>
        if data.message == "arrive"
          channel = @peer.connect remote.peer
          channel.on 'open', =>
            console.info('Initializing ourselves on peer ' + remote.peer)
            @allPeers.push(channel)
      remote.on 'close', =>
        @allPeers = _.reject @allPeers, (channel)-> channel.peer == remote.peer

  broadcastToAllChannels:(data)->
    _.each @allPeers, (connection)->
      connection.send(data)

MS.Network = Network
