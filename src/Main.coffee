MusicalSacrifice = window.MusicalSacrifice

class Main extends Phaser.State
  constructor:(@parent='')->

  run:(debug = false)->
    mode = if debug then Phaser.CANVAS else Phaser.AUTO
    new Phaser.Game(800, 450, mode, @parent, this, false, false, null)

  init: ->
    @game.physics.startSystem(Phaser.Physics.ARCADE)

    @game.input.gamepad.start
    @pads = [
      @game.input.gamepad.pad1,
      @game.input.gamepad.pad2,
      @game.input.gamepad.pad3,
      @game.input.gamepad.pad4
    ]

    @kb = @game.input.keyboard
    @kb.addKeyCapture([
      Phaser.Keyboard.W,
      Phaser.Keyboard.A,
      Phaser.Keyboard.S,
      Phaser.Keyboard.D,
      Phaser.Keyboard.UP,
      Phaser.Keyboard.DOWN,
      Phaser.Keyboard.LEFT,
      Phaser.Keyboard.RIGHT,
    ])

    @game.scale.scaleMode = Phaser.ScaleManager.SHOW_ALL
    @game.scale.pageAlignVertically = true
    @game.scale.pageAlignHorizontally = true

    @game.stage.backgroundColor = 0x886666;

  create: ->
    @dudesById = {}
    @myId = '555'

    @dudes = @game.add.group()
    @player = @addDude(@myId, 0, 0, 'nigel')

    @game.physics.arcade.enable(@player)
    console.log(@dudes)
    @cursors = @game.input.keyboard.createCursorKeys()

    @peer = new Peer({ debug: 3, host: 'router.kranzky.com', port: 80, config: { 'iceServers': [] } })

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
    dude.animations.add("down", [0, 1, 2, 1], 20, true)
    dude.animations.add("left", [4, 5, 6, 5], 10, true)
    dude.animations.add("right", [8, 9, 10, 9], 10, true)
    dude.animations.add("up", [12, 13, 14, 13], 20, true)
    dude.animations.add("idle", [1], 20, true)
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
    moves = @pollController()
    if (moves.left)
      @player.body.velocity.x = -150
    if (moves.right)
      @player.body.velocity.x = 150
    if (moves.up)
      @player.body.velocity.y = -150
    if (moves.down)
      @player.body.velocity.y = 150

    animation = "idle"
    if Math.abs(@player.body.velocity.x) > Math.abs(@player.body.velocity.y)
      if @player.body.velocity.x > 25
        animation = "right"
      else if @player.body.velocity.x < -25
        animation = "left"
    else
      if @player.body.velocity.y > 25
        animation = "down"
      else if @player.body.velocity.y < -25
        animation = "up"
    @player.animations.play(animation)

    @player.body.velocity.x *= 0.95
    @player.body.velocity.y *= 0.95

    @sendUpdate(@myId, @player.body.x, @player.body.y)

  pollController:=>
    moves =
      up: false
      down: false
      left: false
      right: false
      but1: false
      but2: false
      but3: false
      but4: false

#   _.each @pads, (pad)=>
#     if pad.axis(Phaser.Gamepad.XBOX360_STICK_LEFT_Y) < -0.8 or
#        pad.axis(Phaser.Gamepad.XBOX360_STICK_RIGHT_Y) < -0.8 or
#        pad.isDown(Phaser.Gamepad.XBOX360_DPAD_UP)
#       moves.up = true
#     if pad.axis(Phaser.Gamepad.XBOX360_STICK_LEFT_Y) > 0.8
#        pad.axis(Phaser.Gamepad.XBOX360_STICK_RIGHT_Y) > 0.8 or
#        pad.isDown(Phaser.Gamepad.XBOX360_DPAD_DOWN)
#       moves.down = true
#     if pad.axis(Phaser.Gamepad.XBOX360_STICK_LEFT_X) < -0.8
#        pad.axis(Phaser.Gamepad.XBOX360_STICK_RIGHT_X) < -0.8 or
#        pad.isDown(Phaser.Gamepad.XBOX360_DPAD_LEFT)
#       moves.left = true
#     if pad.axis(Phaser.Gamepad.XBOX360_STICK_LEFT_X) > 0.8
#        pad.axis(Phaser.Gamepad.XBOX360_STICK_RIGHT_X) > 0.8 or
#        pad.isDown(Phaser.Gamepad.XBOX360_DPAD_RIGHT)
#       moves.right = true
#     if pad.isDown(Phaser.Gamepad.XBOX360_Y)
#       moves.but1 = true
#     if pad.isDown(Phaser.Gamepad.XBOX360_A)
#       moves.but2 = true
#     if pad.isDown(Phaser.Gamepad.XBOX360_X)
#       moves.but2 = true
#     if pad.isDown(Phaser.Gamepad.XBOX360_B)
#       moves.but2 = true

    if @kb.isDown(Phaser.Keyboard.UP)
      moves.up = true
    if @kb.isDown(Phaser.Keyboard.DOWN)
      moves.down = true
    if @kb.isDown(Phaser.Keyboard.LEFT)
      moves.left = true
    if @kb.isDown(Phaser.Keyboard.RIGHT)
      moves.right = true
    if @kb.isDown(Phaser.Keyboard.W)
      moves.but1 = true
    if @kb.isDown(Phaser.Keyboard.S)
      moves.but1 = true
    if @kb.isDown(Phaser.Keyboard.A)
      moves.but1 = true
    if @kb.isDown(Phaser.Keyboard.D)
      moves.but1 = true

    moves

  sendUpdate:(id, x, y) ->
    _.each @allPeers, (connection)->
      connection.send({message: "update", x: x, y: y})

  destroy:->

  preload:->
    @game.load.spritesheet('nigel', 'assets/nigel.png', 32, 32)

  loadRender:->

  render:->

  ready:=>

  startGame:=>

MusicalSacrifice.Main = Main
