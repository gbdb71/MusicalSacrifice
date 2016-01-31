MS = window.MusicalSacrifice

class LobbyState extends Phaser.State
  create:->
    pitch = @game.add.sprite(@game.world.centerX, @game.world.centerY, 'william')
    pitch.anchor.setTo(0.5, 0.5)
    pitch.width = 800
    pitch.height = 450
    @backgroundGroup = @game.add.group()
    @playerGroup = @game.add.group()
    @header ="=== MUSICAL SACRIFICE ==="
    message ="#{@header}\n\nConnecting..."
    style =
      font: "30px Courier"
      fill: "#00ff44"
      align: "center"
    @text = @game.add.text(@game.world.centerX, @game.world.centerY, message, style)
    @text.anchor.setTo(0.5, 0.5)

  update:->
    gm = @game.entityManager.getGM()
    nextLevel = gm?.nextLevel
    if nextLevel?
      message = "Next Up: #{nextLevel}"
      if gm.intermissionMessage
        message = "#{gm.intermissionMessage}\n\n#{message}"

      @text.setText("#{@header}\n\n#{message}")

    @game.entityManager.update()

MS.LobbyState = LobbyState
