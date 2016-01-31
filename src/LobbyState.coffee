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
      message = "..."
      if nextLevel == "Yorick"
        @header = "ALAS, POOR YORICK!"
        message = "Pass the ballskull around and make\n"+
                  "sure everyone gets a touch. Deliver\n"+
                  "a monologue if you dare!"
      if nextLevel == "Cleaning"
        @header = "OUT, DAMN'D SPOT!"
        message = "Help Lady Macbeth clean the blood\n"+
                  "from the floorboards... get every\n"+
                  "drop to win!"
      if nextLevel == "Acting"
        @header = "WHAT LIGHT THROUGH YONDER WINDOW!"
        message = "Woo your fellow players..."
      if nextLevel == "Killing"
        @header = "ET TU, BRUTE!"
        message = "Grab the knives... whoever is last gets\n"+
                  "to be killed :("
      if gm.intermissionMessage
        message = "#{gm.intermissionMessage}\n\n#{message}"
      @text.setText("#{@header}\n\n#{message}")
      @text.anchor.setTo(0.5, 0)
      @text.position.y = 100
    @game.entityManager.update()

MS.LobbyState = LobbyState
