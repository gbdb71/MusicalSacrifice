MS = window.MusicalSacrifice

class LobbyState extends Phaser.State
  create: ->

  update:->
    @game.entityManager.update()

MS.LobbyState = LobbyState
