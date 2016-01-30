MS = window.MusicalSacrifice

class LobbyState extends Phaser.State
  create: ->
    @game.state.start("Soccer")

MS.LobbyState = LobbyState
