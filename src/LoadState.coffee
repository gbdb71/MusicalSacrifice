MS = window.MusicalSacrifice

class LoadState extends Phaser.State
  SHEETS = ['animals1', 'bonus1', 'chara2', 'chara3', 'chara4', 'chara5',
            'military1', 'military2', 'military3', 'npc1', 'npc2', 'npc3', 'npc4']

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
    @progress = 0
    @game.sheets = SHEETS

  preload:->
    _.each SHEETS, (name)=>
      @game.load.spritesheet(name, 'assets/' + name + '.png', 26, 36)
    @game.load.spritesheet('ball', 'assets/skull.png', 16, 16)
    @game.load.image('shadow', 'assets/shadow.png')
    @game.load.image('soccer', 'assets/soccer.jpg')
    @game.load.image('cleaning', 'assets/cleaning.jpg')
    @game.load.image('acting', 'assets/acting.jpg')
    @game.load.image('killing', 'assets/killing.jpg')
    @game.load.image('william', 'assets/shakespeare.jpg')

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
