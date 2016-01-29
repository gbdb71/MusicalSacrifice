MusicalSacrifice = window.MusicalSacrifice

class Splash extends Phaser.State
  constructor:->

  create:->
    @game.stage.backgroundColor = '#FFFFFF'

  destroy:->

  done:=>
    @game.state.start('landscape')

MusicalSacrifice.Splash = Splash
