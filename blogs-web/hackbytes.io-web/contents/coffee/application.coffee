mixitup = require('mixitup')
# jcarousel is a pikachoose dependency
# it needs to be called here since the pikachoose package doesn't import it in it's js code
jcarousel = require('pikachoose/lib/jquery.jcarousel.min.js')
pikachoose = require('pikachoose')

$(document).ready(() ->

  # Foundation
  $(document).foundation().foundation('start')

  onMixEndCallback = () ->
    # Simple parallax effect
    $('.portfoliolist .portfolio').hover(
      () ->
        $(this).find('.portfolio-item').fadeTo(0, 0.5)
    ,
      () ->
        $(this).find('.portfolio-item').fadeTo(0, 1)
    )

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

  # Run portfolio code
  #
  # MixItUp plugin
  # http://mixitup.io
  containerEl = document.querySelector('.portfoliolist')

  if containerEl
    mixer = mixitup(containerEl, {
      selectors: {
        target: '.portfolio'
      },
      # Set a 'stagger' effect for the loading animation
      animation: {
        effects: 'fade scale stagger(50ms)'
      },
      # Ensure all targets start from hidden (i.e. display: none;)
      load: {
        filter: 'none'
      }
      callbacks: {
        onMixEnd: onMixEndCallback()
      }
    })

    # With the migration from v2 -> v3, we now have to specify an "intro" or "init" page
    # animation manually. So that's what we're doing here with mixer.
    #
    # See more: https://github.com/patrickkunka/mixitup/issues/228

    # Add a class to the container to remove 'visibility: hidden;' from targets.
    # This prevents any flickr of content before the page's JavaScript has loaded.
    containerEl.classList.add('mixitup-ready');

    # Show all targets in the container
    mixer.show()
      .then(() ->
        # Remove the stagger effect for any subsequent operations
        mixer.configure({
          animation: {
            effects: 'fade scale'
          }
        })
      )

  # Run PikaChoose carousel code
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

