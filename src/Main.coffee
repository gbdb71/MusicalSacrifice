MusicalSacrifice = window.MusicalSacrifice

class Main extends Phaser.State
  constructor:(@parent='')->

  run:(debug = false)->
    mode = if debug then Phaser.CANVAS else Phaser.AUTO
    new Phaser.Game(896, 504, mode, @parent, this)

  create: ->
    @dudesById = {}
    @myId = '555'

    @game.physics.startSystem(Phaser.Physics.ARCADE)

    @dudes = @game.add.group()
    @player = @addDude(@myId, 0, 0, 'dude')

    @game.physics.arcade.enable(@player)
    console.log(@dudes)
    @cursors = @game.input.keyboard.createCursorKeys()

    @peer = new Peer({ debug: 0, host: 'router.kranzky.com', port: 80 })

    @allPeers = []
    @myPeerId = null
    @peer.on 'open', (id)=>
      console.log('My peer ID is: ' + id)
      @myPeerId = id
      @peer.listAllPeers (data)=>
        data = _.without(data, @myPeerId)
        @allPeers = _.map data, (peerId) =>
          channel = @peer.connect(peerId)
          channel.on 'open', =>
            channel.send({message:"arrive"})
            @addDude(channel.peer, data.x, data.y)
          channel

        console.log('all peers: ' + _.map @allPeers, (channel)->channel.peer )


    @peer.on 'connection', (remote)=>
      remote.on 'data', (data)=>
        if data.message == "update"
          @updateDude(remote.peer, data.x, data.y)
        else if data.message == "arrive"
          console.info(data)
          channel = @peer.connect remote.peer
          @allPeers.push(channel)
          console.log('all peers: ' + _.map @allPeers, (channel)->channel.peer)
          @addDude(remote.peer, data.x, data.y)
      remote.on 'close', =>
        @allPeers = _.reject @allPeers, (channel)-> channel.peer == remote.peer
        @removeDude(remote.peer)

  addDude:(dudeId, x, y)->
    dude = @dudes.create(x, y, 'dude')
    @dudesById[dudeId] = dude
    dude

  removeDude:(dudeId)->
    dude = @dudesById[dudeId]
    dude.kill()
    delete @dudesById[dudeId]

  updateDude:(dudeId, x, y)->
    dude = @dudesById[dudeId]
    dude.position.x = x
    dude.position.y = y

  update:->
    @player.body.velocity.x = 0

    if (@cursors.left.isDown)
      @player.body.velocity.x = -150
      @player.animations.play('left')
    else if (@cursors.right.isDown)
      @player.body.velocity.x = 150
      @player.animations.play('right')
    else
      @player.animations.stop()
      @player.frame = 4

    @sendUpdate(@myId, @player.body.x, @player.body.y)

  sendUpdate:(id, x, y) ->
    _.each @allPeers, (connection)->
      connection.send({message: "update", x: x, y: y})

  destroy:->

  preload:->
    @game.load.image('dude', 'assets/dude.png')

  loadRender:->

  render:->

  ready:=>

  startGame:=>

MusicalSacrifice.Main = Main
