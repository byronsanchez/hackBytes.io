=begin

Checks to see if pagination is enabled for a particular page. All pages
with pagination disabled are skipped, with the subsequent page being
rendered as the previous/next page (if it has pagination enabled).
Pagination is enabled by default and turned off explicitly in the YAML
front-matter.

=end

module Jekyll

  class PaginationGenerator < Generator

    safe true

    # Generate skippable pages for the paginator. Loops through each
    # post and removes all pages that have pagination disabled.
    #
    # site - The Site.
    #
    # Returns nothing.
    def generate(site)
      update_post_timeline(site, site.config)
      build_category_pager(site, site.config)
      site.posts.each do |post|
        build_pager(site, post)
      end
    end

    # Determines whether or not pagination is disabled for a particular
    # post. The default state (if a post doesn't explicitly define it's
    # individual pagination boolean) is determined by the config file.
    #
    # config - The configuration Hash. Used for the site-wide default
    #          for pagination_enabled
    # comments_enabled - The Boolean for whether or not pagination is
    #                    enabled. This is set in the posts file.
    #
    # Returns true if pagination is enabled for this post, false
    # otherwise.
    def pagination_enabled?(config, pagination_enabled)
      # Check if the post's pagination_enabled variable was defined. If so,
      # it takes precedence.
      if pagination_enabled.nil?
        # If pagination_enabled is NOT defined, get the value from the
        # config file.
        if config['pagination_enabled'].nil?
          # If the config file isn't defined, we default to on.
          return true;
        else
          return config['pagination_enabled']
        end
      else
        return pagination_enabled
      end
    end

    # Builds a category pager that can be used to navigate through
    # all pages in a single category.
    #
    # site - The Site.
    # config - The configuration Hash. Used for determining whether
    # a pagination extension has been enabled. More extensions increase
    # site compile time, so these extensions are off by default.
    #
    # Returns nothing.
    def build_category_pager(site, config)
      # Build a category pager if enabled in _config.yml
      unless site.config['pagination_extensions'].nil?
        if site.config['pagination_extensions'].include? 'categories'
          site.categories.each do |category|
            category_name = category[0]
            # Must be updated in place so that the post indexes match
            # the category filters. Otherwise, the array will be sorted
            # by the default global order based on published date as
            # opposed to category.
            category[1].sort_by! {|s| s.date.to_i }.each do |post|
              # Initialize category array if needed.
              if post.data[category_name].nil?
                post.data[category_name] = Hash.new
              end
              current_post_index = category[1].index(post)
              prev_post_index = current_post_index - 1
              next_post_index = current_post_index + 1
              # lower bound
              if current_post_index <= 0
                post.data[category_name]['smart_previous'] = nil
              # upper bound
              elsif current_post_index >= category[1].length - 1
                post.data[category_name]['smart_next'] = nil
              # everything else
              else
                post.data[category_name]['smart_previous'] = category[1][prev_post_index]
                post.data[category_name]['smart_next'] = category[1][next_post_index]
              end
            end
          end
        end
      end
    end

    # Removes a post from the paginator timeline. This function will
    # then update the necessary "previous" and next values so that a
    # post who has the pagination boolean set to false is not part of
    # the pager traversal. In essence, this page will get "skipped."
    #
    # site - The Site.
    # post - The post object for which we are removing from the
    #        paginator timeline.
    #
    # Returns nothing
    def build_pager(site, post)
      
      # Omit specified pages from the pager timeline.
      if post.data['pagination_enabled'] == false || post.data['pagination_enabled'] == 0
        current_post_index = site.posts.index(post)
        prev_post_index = current_post_index - 1
        next_post_index = current_post_index + 1

        # Increment the indexes until a valid post is found or until we
        # reach the end of the array
        while prev_post_index >= 0 && site.posts[prev_post_index].data['pagination_enabled'] == false
          prev_post_index -= 1
        end
        while next_post_index <= (site.posts.length - 1) && site.posts[next_post_index].data['pagination_enabled'] == false
          next_post_index += 1
        end

        post.data['smart_next'] = nil
        post.data['smart_previous'] = nil

        # both in bounds
        if prev_post_index >= 0 && next_post_index <= site.posts.length - 1
          site.posts[prev_post_index].data['smart_next'] = site.posts[next_post_index]
          site.posts[next_post_index].data['smart_previous'] = site.posts[prev_post_index]
        end
        # both out of bounds
        if prev_post_index < 0 && next_post_index > site.posts.length - 1
          # Can't do anything.
        end
        # prev_post_index out of bounds
        if prev_post_index < 0 && next_post_index <= site.posts.length - 1
          site.posts[next_post_index].data['smart_previous'] = nil
        end
        # next_post_index out of bounds
        if prev_post_index >= 0 && next_post_index > site.posts.length - 1
          site.posts[prev_post_index].data['smart_next'] = nil
        end
      end
    end

    # Updates every post configuration with the default pagination
    # value as defined by the config file, the yaml-front matter, or
    # the default plugin setting. Also sets up the default pagination
    # timeline under the "smart_previous" and "smart_next" elements.
    # These are accessible by Liquid.
    #
    # site - The Site.
    # config - The configuration Hash. Used for the site-wide default
    #          for pagination_enabled.
    #
    # Returns nothing.
    def update_post_timeline(site, config)
      site.posts.each do |post|
        post.data['smart_previous'] = post.previous
        post.data['smart_next'] = post.next
        # This might seem redundant, but this helps ensure that no
        # matter which case may occur, pagination_enabled will always
        # contain some valid value.
        post.data['pagination_enabled'] = pagination_enabled?(site.config, post.data['pagination_enabled'])
      end
    end
  end
  
end
