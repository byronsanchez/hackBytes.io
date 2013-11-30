module Jekyll

  class CommentGenerator < Generator

    safe true

    # Generate commented pages. Loops through each post and attaches a comment
    # array containing Hashes. One comment array per post.
    #
    # site - The Site.
    #
    # Returns nothing.
    def generate(site)
      site.posts.dup.each do |post|
        # This might seem redundant, but this helps ensure that no matter which case may
        # occur, comments_enabled will always have some valid value.
        post.data['comments_enabled'] = comments_enabled?(site.config, post.data['comments_enabled'])
        
        if post.data['comments_enabled'] == true || post.data['comments_enabled'] == 1
          attach_comments(site, post)
        end
      end
    end
    
    # Determines whether or not comments are enabled for a particular
    # post. The default state (if a post doesn't explicitly define it's
    # individual comment boolean) is determined by the _config file.
    #
    # config - The configuration Hash. Used for the site-wide default for
    #          comments_enabled
    # comments_enabled - The Boolean for whether or not comments are enabled.
    #                    This is set in the comment's file.
    #
    # Returns true if comments are enabled for this post, false otherwise.
    def comments_enabled?(config, comments_enabled)
      # Check if the post's comment_enabled variable was defined. If so,
      # it takes precedence.
      if comments_enabled.nil?
        # If comments_enabled is NOT defined, get the value from the
        # config file.
        if config['comments_enabled'].nil?
          # If the config file isn't defined, we default to off.
          return false;
        else
          return config['comments_enabled']
        end
      else
        return comments_enabled
      end
    end
    
    # Attaches comments to it's corresponding blog post. This function
    # creates a comments array for an individual post object and makes
    # the array available to Liquid. Renders each comment's markdown
    # as well, based on the comment file's extension.
    #
    # site - The Site.
    # post - The post object for which we are generating comments.
    #
    # Returns nothing.
    def attach_comments(site, post)
      # Ensure a new set of comments every post iteration.
      @comments = []
      
      # Build a hash of comments for this particular post object.
      Dir.glob(File.join(site.source, '_comments') + "/**/*").sort_by! {|s| s[/\d+/].to_i}.each do |item|
        next if File.directory?(item)
        # do work on real items
        comment_hash = (self.read_comment_yaml(item, post, site))
        unless comment_hash.nil?
          @comments << comment_hash
        end
      end
      
      # Set "number of comments" variable and make it available to Liquid.
      comments_num = @comments.length
      post.data['comments_num'] = comments_num
      
      # Make the comments array available to Liquid.
      post.data['comments'] = @comments
    end
    
    # Reads the YAML frontmatter as well as the content below the
    # front-matter. Then, converts the markdown in the content.
    # Finally, creates a Hash containing all data for the current
    # comment iteration.
    #
    # item - The String filename of the file.
    # post - The post object for which we are generating comments.
    # site - The Site.
    #
    # Returns a Hash containing all data of the current comment
    # iteration.
    def read_comment_yaml(item, post, site)
      comment_content = File.read(item)
      
      begin
        if comment_content =~ /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m
          comment_content = $POSTMATCH
          comment_data = YAML.load($1)
        end
      rescue => e
      end

      if comment_data['post_id'] == post.id
        post_comments = comment_data
        converter_instance = converter(item, site)
        post_comments['comment'] = converter_instance.convert(comment_content)
      end
      
      post_comments
    end
    
    # Determines which converter to use based on the file's extension.
    #
    # item - The name of the file containing the comment.
    # Site - The Site.
    #
    # Returns the Converter instance.
    def converter(item, site)
      ext = File.extname(item)
      @converter ||= site.converters.find { |c| c.matches(ext) }
    end
  end

end
