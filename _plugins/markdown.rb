# Customized core file on a custom jekyll build

RUBY_FILE = File.join(File.dirname(".."), "assets", "bs-markdown.rb")

require RUBY_FILE

module Jekyll

  class MarkdownConverter < Converter

    pygments_prefix "\n"
    pygments_suffix "\n"

    def setup
      return if @setup
      case @config['markdown']
        when 'redcarpet'
          begin
            #require 'redcarpet'

            @renderer ||= HTMLwithPygments

            @redcarpet_extensions = {}
            @config['redcarpet']['extensions'].each { |e| @redcarpet_extensions[e.to_sym] = true }
          rescue LoadError
            STDERR.puts 'You are missing a library required for Markdown. Please run:'
            STDERR.puts '  $ [sudo] gem install redcarpet'
            raise FatalException.new("Missing dependency: redcarpet")
          end
        when 'kramdown'
          begin
            require 'kramdown'
          rescue LoadError
            STDERR.puts 'You are missing a library required for Markdown. Please run:'
            STDERR.puts '  $ [sudo] gem install kramdown'
            raise FatalException.new("Missing dependency: kramdown")
          end
        when 'rdiscount'
          begin
            require 'rdiscount'
            @rdiscount_extensions = @config['rdiscount']['extensions'].map { |e| e.to_sym }
          rescue LoadError
            STDERR.puts 'You are missing a library required for Markdown. Please run:'
            STDERR.puts '  $ [sudo] gem install rdiscount'
            raise FatalException.new("Missing dependency: rdiscount")
          end
        when 'maruku'
          begin
            require 'maruku'

            if @config['maruku']['use_divs']
              require 'maruku/ext/div'
              STDERR.puts 'Maruku: Using extended syntax for div elements.'
            end

            if @config['maruku']['use_tex']
              require 'maruku/ext/math'
              STDERR.puts "Maruku: Using LaTeX extension. Images in `#{@config['maruku']['png_dir']}`."

              # Switch off MathML output
              MaRuKu::Globals[:html_math_output_mathml] = false
              MaRuKu::Globals[:html_math_engine] = 'none'

              # Turn on math to PNG support with blahtex
              # Resulting PNGs stored in `images/latex`
              MaRuKu::Globals[:html_math_output_png] = true
              MaRuKu::Globals[:html_png_engine] =  @config['maruku']['png_engine']
              MaRuKu::Globals[:html_png_dir] = @config['maruku']['png_dir']
              MaRuKu::Globals[:html_png_url] = @config['maruku']['png_url']
            end
          rescue LoadError
            STDERR.puts 'You are missing a library required for Markdown. Please run:'
            STDERR.puts '  $ [sudo] gem install maruku'
            raise FatalException.new("Missing dependency: maruku")
          end
        else
          STDERR.puts "Invalid Markdown processor: #{@config['markdown']}"
          STDERR.puts "  Valid options are [ maruku | rdiscount | kramdown ]"
          raise FatalException.new("Invalid Markdown process: #{@config['markdown']}")
      end
      @setup = true
    end
    
    def matches(ext)
      rgx = '(' + @config['markdown_ext'].gsub(',','|') +')'
      ext =~ Regexp.new(rgx, Regexp::IGNORECASE)
    end

    def output_ext(ext)
      ".html"
    end

    def convert(content)
      setup
      case @config['markdown']
        when 'redcarpet'
          @redcarpet_extensions[:fenced_code_blocks] = !@redcarpet_extensions[:no_fenced_code_blocks]
          @renderer.send :include, Redcarpet::Render::SmartyPants if @redcarpet_extensions[:smart]
          markdown = Redcarpet::Markdown.new(@renderer.new(@redcarpet_extensions), @redcarpet_extensions)
          output = markdown.render(content)
          output = render_table_headers(output)
          render_footnotes(output)
        when 'kramdown'
          # Check for use of coderay
          if @config['kramdown']['use_coderay']
            Kramdown::Document.new(content, {
              :auto_ids      => @config['kramdown']['auto_ids'],
              :footnote_nr   => @config['kramdown']['footnote_nr'],
              :entity_output => @config['kramdown']['entity_output'],
              :toc_levels    => @config['kramdown']['toc_levels'],
              :smart_quotes  => @config['kramdown']['smart_quotes'],

              :coderay_wrap               => @config['kramdown']['coderay']['coderay_wrap'],
              :coderay_line_numbers       => @config['kramdown']['coderay']['coderay_line_numbers'],
              :coderay_line_number_start  => @config['kramdown']['coderay']['coderay_line_number_start'],
              :coderay_tab_width          => @config['kramdown']['coderay']['coderay_tab_width'],
              :coderay_bold_every         => @config['kramdown']['coderay']['coderay_bold_every'],
              :coderay_css                => @config['kramdown']['coderay']['coderay_css']
            }).to_html
          else
            # not using coderay
            Kramdown::Document.new(content, {
              :auto_ids      => @config['kramdown']['auto_ids'],
              :footnote_nr   => @config['kramdown']['footnote_nr'],
              :entity_output => @config['kramdown']['entity_output'],
              :toc_levels    => @config['kramdown']['toc_levels'],
              :smart_quotes  => @config['kramdown']['smart_quotes']
            }).to_html
          end
        when 'rdiscount'
          rd = RDiscount.new(content, *@rdiscount_extensions)
          html = rd.to_html
          if rd.generate_toc and html.include?(@config['rdiscount']['toc_token'])
            html.gsub!(@config['rdiscount']['toc_token'], rd.toc_content)
          end
          html
        when 'maruku'
          Maruku.new(content).to_html
      end
    end

    def render_table_headers(html)
      syntax = /<table><thead>(.+?)<\/thead><tbody>(.+?)<\/tbody><\/table>/m
      # Load the data
      results = html.to_enum(:scan, syntax).map { Regexp.last_match }.map! { |x| x.to_s }
      matches = results.dup
  
      if results.nil? || results.empty?
        html
      else
        # Modify the data
        results.map! { |table|
          th_array = Array.new
          i = 0
          j = 0
          table = table.lines.map { |line|
            # If string contains th, copy the value locally and insert it to axis
            table_match = /(<table>)/.match(line)
            th_match = /<th>(.+?)<\/th>/.match(line)
            td_match =  /(<td>.+?<\/td>)/.match(line)
            if table_match
              line.sub!(/<table>/, '<table class="headers">')
              line
            elsif th_match
              th_array.push(th_match[1])
              line.sub!(/<th>/, '<th axis="' + th_array[j] + '">')
              j += 1
              line
            elsif td_match
              if i >= j
                i = 0
              end
              line.sub!(/<td>/, '<td axis="' + th_array[i] + '">')
              i += 1
              line
            else
              line
            end
          }.join

          table
        }

        matches.zip(results).each do |match, result|
          html.sub!(match, result)
        end
        html
      end
    end

    # Yet another hack to let us customize the styling for footnotes.
    def render_footnotes(html)
      syntax = /<div class="footnotes">\s*?<hr>/m
      html.gsub!(syntax, '<div class="footnotes">')
    end
  end

end
