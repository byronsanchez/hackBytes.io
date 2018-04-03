mixitup = require('mixitup')

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
)

