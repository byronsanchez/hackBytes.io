$(document).ready( () ->

    # Run portfolio code
    filterList = {

      init: ( () ->

        # MixItUp plugin
        # http://mixitup.io
        $('#portfoliolist').mixItUp({
          callbacks: {
            # call the hover effect
            onMixEnd: filterList.hoverEffect()
          },
          selectors: {
            target: '.portfolio',
            filter: '.filter',
            sort: '.sort'
          }
        })

      ),

      hoverEffect: ( () ->

        # Simple parallax effect
        $('#portfoliolist .portfolio').hover(
          () ->
            $(this).find('.portfolio-item').fadeTo(0, 0.5)
          ,
          () ->
            $(this).find('.portfolio-item').fadeTo(0, 1)
        )

      )

    }

    # Run the show!
    filterList.init()

)

