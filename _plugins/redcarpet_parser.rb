module Jekyll
  module Converters
    class Markdown
      class RedcarpetParser

        module CommonMethods
          def add_code_tags(code, lang)
            code = code.sub(/<pre>/, "<pre><code class=\"#{lang} language-#{lang}\" data-lang=\"#{lang}\">")
            code = code.sub(/<\/pre>/,"</code></pre>")
          end
        end

        module WithPygments
          include CommonMethods
          def block_code(code, lang)
            require 'pygments'
            lang = lang && lang.split.first || "text"
            output = add_code_tags(
              Pygments.highlight(code, :lexer => lang, :options => { :encoding => 'utf-8' }),
              lang
            )
          end
        end

        module WithoutPygments
          require 'cgi'

          include CommonMethods

          def code_wrap(code)
            "<div class=\"highlight\"><pre>#{CGI::escapeHTML(code)}</pre></div>"
          end

          def block_code(code, lang)
            lang = lang && lang.split.first || "text"
            output = add_code_tags(code_wrap(code), lang)
          end
        end

        #!-- CUSTOM --#
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
          html
        end
        #!-- END CUSTOM --#
        
        def initialize(config)
          #!-- CUSTOM --#
          #require 'redcarpet'
          @renderer ||= HTMLwithPygments
          #!-- /ENDCUSTOM --#
          @config = config
          @redcarpet_extensions = {}
          @config['redcarpet']['extensions'].each { |e| @redcarpet_extensions[e.to_sym] = true }

          @renderer ||= if @config['pygments']
                          Class.new(Redcarpet::Render::HTML) do
                            include WithPygments
                          end
                        else
                          Class.new(Redcarpet::Render::HTML) do
                            include WithoutPygments
                          end
                        end
        rescue LoadError
          STDERR.puts 'You are missing a library required for Markdown. Please run:'
          STDERR.puts '  $ [sudo] gem install redcarpet'
          raise FatalException.new("Missing dependency: redcarpet")
        end

        def convert(content)
          @redcarpet_extensions[:fenced_code_blocks] = !@redcarpet_extensions[:no_fenced_code_blocks]
          @renderer.send :include, Redcarpet::Render::SmartyPants if @redcarpet_extensions[:smart]
          markdown = Redcarpet::Markdown.new(@renderer.new(@redcarpet_extensions), @redcarpet_extensions)
          #!-- CUSTOM ---#
          output = markdown.render(content)
          output = render_table_headers(output)
          render_footnotes(output)
          #!-- /END CUSTOM ---#
        end
      end
    end
  end
end
