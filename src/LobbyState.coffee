MS = window.MusicalSacrifice

class LobbyState extends Phaser.State
  init: ->
    message = "=== MUSICAL SACRIFICE ===\nConnecting..."
    style =
      font: "30px Courier"
      fill: "#00ff44"
      align: "center"
    @text = @game.add.text(@game.world.centerX, @game.world.centerY, message, style)
    @text.anchor.setTo(0.5, 0.5)

  update:->
    @game.entityManager.update()

MS.LobbyState = LobbyState
