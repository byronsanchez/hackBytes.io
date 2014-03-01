// General JS for the site.
$(document).ready(function () {

    "use strict";

    // Scroll variables.
    var $target = $('.bs-docs-sidenav'),
        $window = $(window),
        //$html = $('html'),

        // Affix properties.
        $offset = -1,
        $lastOffset = -1,
        $marginTop = -1,
        $marginOffset = -1,

        // Calculation properties.
        $vps = -1,
        $cst = -1,
        $t = -1,
        $sb = -1,
        $currentPosition = -1,
        $threshold = -1,

        // Header references for determining margin offset and default affix positioning.
        $headerNavbar = $('.navbar'),
        $headerMasthead = $('.masthead'),

        // Footer references for determing where the threshold is (before scroll conversion).
        $footerContact = $('.footer-contact'),
        $footerBottom = $('.footer-bottom');

    /**
     * Calculates the height across all browsers.
     */
    $.getDocHeight = function() {
        return Math.max(
            $(document).height(),
            $(window).height(),
            /* For opera: */
            document.documentElement.clientHeight
        );
    };

    /**
     * Calculates the current scroll position.
     */
    function updateScrollPosition() {
        $cst = $window.scrollTop();
        $t = $.getDocHeight();

        $currentPosition = $t - $cst;
    }

    /**
     * Calculates the threshold at which the target should begin to scroll up.
     */
    function updateScrollThreshold() {
        $vps = $footerContact.outerHeight() + $footerBottom.outerHeight();
        $sb = $target.outerHeight();

        $threshold = $vps + $sb;
    }

    /**
     * Calculates the offset of the target, relative to the top of the page.
     * This is used as the point at which the target fixed, after being affixed.
     * This is ALSO used to determine the scroll threshold IF the navbar is
     * fixed on the top of the page.
     */
    function updateTargetOffsetTop() {
        $marginTop = ($window.width() > 979 ? $headerNavbar.outerHeight() :
                0);
    }

    /**
     * Calculate the "affix-offset." This is the amount the user must scroll
     * in order to trigger the affixed state. Scolling past this
     * "affix-threshold" results in the target's state changing to affixed.
     * Scrolling anywhere BEFORE this threshold result in the target's state
     * changing to not-affixed.
     */
    function updateTargetOffsetAffix() {
        // 979 or lower means the navbar is NOT fixed and must be included in the
        // affix-offset calculation.
        if ($window.width() <= 979) {
            $marginOffset = $headerNavbar.outerHeight() + $headerMasthead.outerHeight();
        } else {
            // Else it's fixed and $marginTop takes care of the navbar-variable.
            $marginOffset = $headerMasthead.outerHeight();
        }
    }

    function updateWindow() {

        // If the window is less than 768, we don't use affix at all. So only run
        // all the ops if the window size is greater than 767.
        if ($window.width() > 767) {

            // Run all calculations to get accurate metrics.
            updateScrollPosition();
            updateScrollThreshold();
            updateTargetOffsetTop();
            updateTargetOffsetAffix();

            // If (total window scroll height - current scroll top) <= (viewport height + sidebarheight)
            // Add any padding or margins relative to the top of the sidebar here.
            if ($currentPosition <= $threshold + $marginTop) {

                $lastOffset = $offset;
                // Determine the offset based on the amount scrolled passed the threshold.
                // offset = (total window scroll height - current scroll top) - (viewport height + sidebarheight)
                $offset = $currentPosition - $threshold;

                // Update the sidebar's position.
                // add offset from sidebar's top positioning.
                if ($offset !== $lastOffset) {
                    //$('.bs-docs-sidenav').animate({ top: $window.width() >= 979 ? $offset : 0 }, 16, 'linear' );
                    $target.css({
                        top: $offset
                    }); // minus an extra pixel for the core-affix 1px margin
                    $target.affix({
                        offset: {
                            //top: function () { return $window.width() <= 980 ? 290 : 210 }
                            // Bootstrap's fixed navbar ceases to be fixed at this width or less.
                            // That's why there now needs to be a top offset equal to the total
                            // spacing between the top of the target and the top of the window.
                            top: function () {
                                return $offset;
                            }
                        }
                    });
                }
            } else {
                $lastOffset = $offset;
                $offset = $marginTop;

                if ($offset !== $lastOffset) {
                    //$('.bs-docs-sidenav').animate({ top: $window.width() >= 979 ? $marginTop : 0 }, 16, 'linear' );
                    $target.css({
                        top: $marginTop
                    });
                    $target.affix({
                        offset: {
                            //top: function () { return $window.width() <= 980 ? 290 : 210 }
                            // Bootstrap's fixed navbar ceases to be fixed at this width or less.
                            // That's why there now needs to be a top offset equal to the total
                            // spacing between the top of the target and the top of the window.
                            top: function () {
                                return $marginOffset;
                            }
                        }
                    });
                }
            }
        }

        // UPDATE SCROLL SPY AFTER ALL UPDATES
        $(document.body).scrollspy('refresh');
    }

    // Disable certain links in docs
    $('section [href^=#]').click(function (e) {
        e.preventDefault();
    });

    // Activate Scroll Spy!
    $(document.body).scrollspy({
        target: ".bs-docs-sidebar"
    });

    // Bind affix calculation and positioning ops to the window's resize and
    // scroll events.
    $(window).bind('resize scroll', function () {
        updateWindow();
    });

    // Set the initial state.
    updateWindow();

    // Run portfolio code
    var filterList = {
    
      init: function () {
      
        // MixItUp plugin
        // http://mixitup.io
        $('#portfoliolist').mixitup({
          targetSelector: '.portfolio',
          filterSelector: '.filter',
          effects: ['fade'],
          easing: 'snap',
          // call the hover effect
          onMixEnd: filterList.hoverEffect()
        });       
      
      },
      
      hoverEffect: function () {
      
        // Simple parallax effect
        $('#portfoliolist .portfolio').hover(
          function () {
            $(this).find('.portfolio-item').fadeTo(0, 0.5);
          },
          function () {
            $(this).find('.portfolio-item').fadeTo(0, 1);
          }
        );        
      
      }

    };
    
    // Run the show!
    filterList.init();
    
});
