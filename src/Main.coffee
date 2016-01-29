MusicalSacrifice = window.MusicalSacrifice

class Main extends Phaser.State
  constructor:(@parent='')->

  run:(debug = false)->
    mode = if debug then Phaser.CANVAS else Phaser.AUTO
    new Phaser.Game(800, 450, mode, @parent, this, false, false, null)

  init: ->
    @game.scale.scaleMode = Phaser.ScaleManager.SHOW_ALL
    @game.scale.pageAlignVertically = true
    @game.scale.pageAlignHorizontally = true

    @game.stage.backgroundColor = 0x886666;

  create: ->
    @dudesById = {}
    @myId = '555'

    @game.physics.startSystem(Phaser.Physics.ARCADE)

    @dudes = @game.add.group()
    @player = @addDude(@myId, 0, 0, 'nigel')

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
    dude = @dudes.create(x, y, 'nigel')
    dude.animations.frame = 1
    dude.animations.add("down", [0, 1, 2, 1], 10, true)
    dude.animations.add("left", [4, 5, 6, 5], 20, true)
    dude.animations.add("right", [8, 9, 10, 9], 10, true)
    dude.animations.add("up", [12, 13, 14, 13], 20, true)
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
    else if (@cursors.up.isDown)
      @player.body.velocity.y = -150
      @player.animations.play('up')
    else if (@cursors.down.isDown)
      @player.body.velocity.y = 150
      @player.animations.play('down')
    else
      @player.animations.stop()
      @player.frame = 4

    @player.body.velocity.x *= 0.5
    @player.body.velocity.y *= 0.5

    @sendUpdate(@myId, @player.body.x, @player.body.y)

  sendUpdate:(id, x, y) ->
    _.each @allPeers, (connection)->
      connection.send({message: "update", x: x, y: y})

  destroy:->

  preload:->
    @game.input.gamepad.start
    @pads = [
      @game.input.gamepad.pad1,
      @game.input.gamepad.pad2,
      @game.input.gamepad.pad3,
      @game.input.gamepad.pad4
    ]
    @game.load.spritesheet('nigel', 'assets/nigel.png', 32, 32)

  loadRender:->

  render:->

  ready:=>

  startGame:=>

MusicalSacrifice.Main = Main
