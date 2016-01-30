MS = window.MusicalSacrifice

class LoadState extends Phaser.State
  init:->
    message = "=== MUSICAL SACRIFICE ===\nis\nLOADING"
    style =
      font: "30px Courier"
      fill: "#00ff44"
      align: "center"
    @text = @game.add.text(@game.world.centerX, @game.world.centerY, message, style)
    @text.anchor.setTo(0.5, 0.5)
    @graphics = @game.add.graphics(0, 0)
    @graphics.lineStyle(1, 0x5588cc, 1)
    @graphics.drawRect(100, 339, 600, 22)
    @prograss = 0

  preload:->
    @game.load.spritesheet('nigel', 'assets/nigel.png', 32, 32)
    @game.load.spritesheet('bruce', 'assets/bruce.png', 32, 32)
    @game.load.spritesheet('julie', 'assets/julie.png', 32, 32)
    @game.load.spritesheet('rachel', 'assets/rachel.png', 32, 32)
    @game.load.image('ball', 'assets/ball.png')

  loadUpdate:->
    @progress = @game.load.progress

  loadRender:->
    @graphics.beginFill(0x00ff44)
    @graphics.drawRect(100, 340, 6 * @progress, 20)
    @graphics.endFill()

  render:-> @loadRender()

  update:->
    @progress = 100
    @game.state.start("Lobby")

MS.LoadState = LoadState
