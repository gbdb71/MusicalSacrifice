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
      Phaser.Keyboard.UP
      Phaser.Keyboard.DOWN,
      Phaser.Keyboard.LEFT,
      Phaser.Keyboard.RIGHT,
      Phaser.Keyboard.ALT
    ])

  init:->
    @buffer = ""
    @message = ""
    @kb.addKey(Phaser.Keyboard.A).onDown.add(@type, @, 0, 'a')
    @kb.addKey(Phaser.Keyboard.B).onDown.add(@type, @, 0, 'b')
    @kb.addKey(Phaser.Keyboard.C).onDown.add(@type, @, 0, 'c')
    @kb.addKey(Phaser.Keyboard.D).onDown.add(@type, @, 0, 'd')
    @kb.addKey(Phaser.Keyboard.E).onDown.add(@type, @, 0, 'e')
    @kb.addKey(Phaser.Keyboard.F).onDown.add(@type, @, 0, 'f')
    @kb.addKey(Phaser.Keyboard.G).onDown.add(@type, @, 0, 'g')
    @kb.addKey(Phaser.Keyboard.H).onDown.add(@type, @, 0, 'h')
    @kb.addKey(Phaser.Keyboard.I).onDown.add(@type, @, 0, 'i')
    @kb.addKey(Phaser.Keyboard.J).onDown.add(@type, @, 0, 'j')
    @kb.addKey(Phaser.Keyboard.K).onDown.add(@type, @, 0, 'k')
    @kb.addKey(Phaser.Keyboard.L).onDown.add(@type, @, 0, 'l')
    @kb.addKey(Phaser.Keyboard.M).onDown.add(@type, @, 0, 'm')
    @kb.addKey(Phaser.Keyboard.N).onDown.add(@type, @, 0, 'n')
    @kb.addKey(Phaser.Keyboard.O).onDown.add(@type, @, 0, 'o')
    @kb.addKey(Phaser.Keyboard.P).onDown.add(@type, @, 0, 'p')
    @kb.addKey(Phaser.Keyboard.Q).onDown.add(@type, @, 0, 'q')
    @kb.addKey(Phaser.Keyboard.R).onDown.add(@type, @, 0, 'r')
    @kb.addKey(Phaser.Keyboard.S).onDown.add(@type, @, 0, 's')
    @kb.addKey(Phaser.Keyboard.T).onDown.add(@type, @, 0, 't')
    @kb.addKey(Phaser.Keyboard.U).onDown.add(@type, @, 0, 'u')
    @kb.addKey(Phaser.Keyboard.V).onDown.add(@type, @, 0, 'v')
    @kb.addKey(Phaser.Keyboard.W).onDown.add(@type, @, 0, 'w')
    @kb.addKey(Phaser.Keyboard.X).onDown.add(@type, @, 0, 'x')
    @kb.addKey(Phaser.Keyboard.Y).onDown.add(@type, @, 0, 'y')
    @kb.addKey(Phaser.Keyboard.ZERO).onDown.add(@type, @, 0, '0', ')')
    @kb.addKey(Phaser.Keyboard.ONE).onDown.add(@type, @, 0, '1', '!')
    @kb.addKey(Phaser.Keyboard.TWO).onDown.add(@type, @, 0, '2', '@')
    @kb.addKey(Phaser.Keyboard.THREE).onDown.add(@type, @, 0, '3', '#')
    @kb.addKey(Phaser.Keyboard.FOUR).onDown.add(@type, @, 0, '4', '$')
    @kb.addKey(Phaser.Keyboard.FIVE).onDown.add(@type, @, 0, '5', '%')
    @kb.addKey(Phaser.Keyboard.SIX).onDown.add(@type, @, 0, '6', '^')
    @kb.addKey(Phaser.Keyboard.SEVEN).onDown.add(@type, @, 0, '7', '&')
    @kb.addKey(Phaser.Keyboard.EIGHT).onDown.add(@type, @, 0, '8', '*')
    @kb.addKey(Phaser.Keyboard.NINE).onDown.add(@type, @, 0, '9', '(')
    @kb.addKey(Phaser.Keyboard.COMMA).onDown.add(@type, @, 0, ',')
    @kb.addKey(Phaser.Keyboard.PERIOD).onDown.add(@type, @, 0, '.')
    @kb.addKey(Phaser.Keyboard.QUESTION_MARK).onDown.add(@type, @, 0, '?')
    @kb.addKey(Phaser.Keyboard.SPACEBAR).onDown.add(@type, @, 0, ' ')
    @kb.addKey(Phaser.Keyboard.BACKSPACE).onDown.add(@type, @, 0)
    @kb.addKey(Phaser.Keyboard.DELETE).onDown.add(@type, @, 0)
    @kb.addKey(Phaser.Keyboard.ENTER).onDown.add(@type, @, 0)
    @kb.addKey(Phaser.Keyboard.ESC).onDown.add(@type, @, 0)

  type:(key, text, upper)=>
    if !text
      if key.keyCode == Phaser.KeyCode.BACKSPACE or
         key.keyCode == Phaser.KeyCode.DELETE
        @buffer = @buffer.slice(0, -1)
      if key.keyCode == Phaser.KeyCode.ESC
        @buffer = ""
      if key.keyCode == Phaser.KeyCode.ENTER
        @message = @buffer
        @buffer = ""
    else if @buffer.length < 16
      if key.shiftKey
        upper = text.toUpperCase() if !upper
        text = upper
      @buffer += text

  poll:->
    moves =
      up: false
      down: false
      left: false
      right: false
      button: false

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
      if pad.isDown(Phaser.Gamepad.XBOX360_A)
        moves.button = true

    if @kb.isDown(Phaser.Keyboard.UP)
      moves.up = true
    if @kb.isDown(Phaser.Keyboard.DOWN)
      moves.down = true
    if @kb.isDown(Phaser.Keyboard.LEFT)
      moves.left = true
    if @kb.isDown(Phaser.Keyboard.RIGHT)
      moves.right = true
    if @kb.isDown(Phaser.Keyboard.ALT)
      moves.button = true

    moves

MS.Controller = Controller
