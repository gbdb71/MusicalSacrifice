PhaserPeer = window.PhaserPeer

class Splash extends Phaser.State
  constructor:->

  create:->
    @game.stage.backgroundColor = '#FFFFFF'

  destroy:->

  done:=>
    @game.state.start('landscape')

PhaserPeer.Splash = Splash
