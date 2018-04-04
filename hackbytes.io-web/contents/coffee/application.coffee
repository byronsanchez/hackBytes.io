mixitup = require('mixitup')
jcarousel = require('pikachoose/lib/jquery.jcarousel.min.js')
pikachoose = require('pikachoose')

$(document).ready(() ->

  # Foundation
  $(document).foundation().foundation('start')

  # Run portfolio code
  #
  # MixItUp plugin
  # http://mixitup.io
  containerEl = document.querySelector('.portfoliolist')

  if containerEl
    mixer = mixitup(containerEl, {
      selectors: {
        target: '.portfolio'
      }
    })

  fancyboxfunctionvar = (self) ->
    console.log "invoking pikachoose fancybox"
    self.anchor.fancybox()

  #centers the main image in pika - stage
  centreImage = (self) ->
    console.log "centering pikachoose image"
    $img = $('.pika-stage img')
    $stage = $('.pika-stage')

    imgHeight = $img.height()
    imgWidth = $img.width()
    stageHeight = $stage.height()
    stageWidth = $stage.width()

    $img.css('margin-top', (stageHeight / 2) - (imgHeight / 2) + "px")
    $img.css('margin-left', (stageWidth / 2) - (imgWidth / 2) + "px")

  containerPika = document.querySelector('#pikame')

  if containerPika
    console.log "Adding pikachoose carousel"
    $('#pikame').pikachoose({
      buildFinished: fancyboxfunctionvar,
      animationFinished: centreImage,
      showCaption: false,
      hoverPause: true
    })

)

