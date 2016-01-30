#= require BootState

MS = window.MusicalSacrifice

class Main
  constructor:(@parent='')->

  run:(debug = false)->
    mode = if debug then Phaser.CANVAS else Phaser.AUTO
    @game = new Phaser.Game(800, 450, mode, @parent, MS.BootState, false, false, null)

MS.Main = Main
