MS = window.MusicalSacrifice

class Controller
  constructor:(@game)->
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

  poll:=>
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

MS.Controller = Controller
