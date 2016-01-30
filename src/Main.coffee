#= require EntityManager

MusicalSacrifice = window.MusicalSacrifice

class Main extends Phaser.State
  constructor:(@parent='')->

  run:(debug = false)->
    mode = if debug then Phaser.CANVAS else Phaser.AUTO
    new Phaser.Game(800, 450, mode, @parent, this, false, false, null)

  preload:->
    @game.load.spritesheet('nigel', 'assets/nigel.png', 32, 32)
    @game.load.spritesheet('bruce', 'assets/bruce.png', 32, 32)
    @game.load.spritesheet('julie', 'assets/julie.png', 32, 32)
    @game.load.spritesheet('rachel', 'assets/rachel.png', 32, 32)
    @game.load.image('ball', 'assets/ball.png')

  init: ->
    @game.stage.disableVisibilityChange = true
    @generator = new Phaser.RandomDataGenerator([(new Date()).getTime()])

    @game.input.gamepad.start()
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
    @entityManager = null
    @spriteGroup = @game.add.group()

    @allPeers = [ ]
    @myPeerId = null
    #@peer = new Peer({ host: 'router.kranzky.com', port: 80, config: { 'iceServers': [] }, debug: 0 })
    @peer = new Peer({ host: 'localhost', port: 9000, config: { 'iceServers': [] }, debug: 0 })
    @peer.on 'open', (id)=>
      console.info('Starting as peer ' + id)
      @myPeerId = id
      @entityManager = new EntityManager(this, @myPeerId)
      # spawn our avatar
      avatar = @entityManager.spawnOwnedEntity('Avatar', {x:400, y:225})
      # also spawn a ball for ourselves
      @entityManager.spawnOwnedEntity('Ball', {x:400, y:225, possessorId: avatar.id})

      @peer.listAllPeers (data)=>
        data = _.without(data, @myPeerId)
        @allPeers = _.map data, (peerId) =>
          channel = @peer.connect(peerId)
          channel.on 'open', =>
            console.info('Joining peer ' + peerId)
            channel.send({ message: "arrive" })
            @entityManager.sendInitForAllOwnedEntitiesToChannel(channel)
          channel
        console.log('all peers: ' + _.map @allPeers, (channel)->channel.peer )

    @peer.on 'connection', (remote)=>
      remote.on 'data', (data)=>
        if data.message == "arrive"
          console.info('Remote peer has arrived ' + remote.peer)
          channel = @peer.connect remote.peer
          channel.on 'open', =>
            console.info('Initializing ourselves on peer ' + remote.peer)
            @entityManager.sendInitForAllOwnedEntitiesToChannel(channel)
            @allPeers.push(channel)
        else if data.message == "initEntity"
          console.info('Peer has initialized themselves ' + remote.peer)
          # someone has just told us about them, so create their dude
          @entityManager.processIncoming(data)
        else if data.message == "update"
          @entityManager.processIncoming(data)
      remote.on 'close', =>
        @allPeers = _.reject @allPeers, (channel)-> channel.peer == remote.peer
        @entityManager.despawnEntitiesForPeerId(remote.peer)

  update:->
    if @entityManager?
      @entityManager.update()

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

    _.each @pads, (pad)=>
      if !pad.connected
        return
      if pad.axis(Phaser.Gamepad.XBOX360_STICK_LEFT_Y) < -0.2 or
         pad.axis(Phaser.Gamepad.XBOX360_STICK_RIGHT_Y) < -0.2 or
         pad.isDown(Phaser.Gamepad.XBOX360_DPAD_UP)
        moves.up = true
      if pad.axis(Phaser.Gamepad.XBOX360_STICK_LEFT_Y) > 0.2 or
         pad.axis(Phaser.Gamepad.XBOX360_STICK_RIGHT_Y) > 0.2 or
         pad.isDown(Phaser.Gamepad.XBOX360_DPAD_DOWN)
        moves.down = true
      if pad.axis(Phaser.Gamepad.XBOX360_STICK_LEFT_X) < -0.2 or
         pad.axis(Phaser.Gamepad.XBOX360_STICK_RIGHT_X) < -0.2 or
         pad.isDown(Phaser.Gamepad.XBOX360_DPAD_LEFT)
        moves.left = true
      if pad.axis(Phaser.Gamepad.XBOX360_STICK_LEFT_X) > 0.2 or
         pad.axis(Phaser.Gamepad.XBOX360_STICK_RIGHT_X) > 0.2 or
         pad.isDown(Phaser.Gamepad.XBOX360_DPAD_RIGHT)
        moves.right = true
      if pad.isDown(Phaser.Gamepad.XBOX360_Y)
        moves.but1 = true
      if pad.isDown(Phaser.Gamepad.XBOX360_A)
        moves.but2 = true
      if pad.isDown(Phaser.Gamepad.XBOX360_X)
        moves.but3 = true
      if pad.isDown(Phaser.Gamepad.XBOX360_B)
        moves.but4 = true

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
      moves.but2 = true
    if @kb.isDown(Phaser.Keyboard.A)
      moves.but3 = true
    if @kb.isDown(Phaser.Keyboard.D)
      moves.but4 = true

    moves

  broadcastToAllChannels:(data)->
    _.each @allPeers, (connection)->
      connection.send(data)

  destroy:->

  loadRender:->

  render:->

  ready:=>

  startGame:=>

MusicalSacrifice.Main = Main
