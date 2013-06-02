# The pygments.rb fix is implemented, but not currently used in favor of the
# tableize function.

module Jekyll
  module Tags
    class HighlightBlock < Liquid::Block
      include Liquid::StandardFilters

      # The regular expression syntax checker. Start with the language specifier.
      # Follow that by zero or more space separated options that take one of two
      # forms:
      #
      # 1. name
      # 2. name=value
      SYNTAX = /^([a-zA-Z0-9.+#-]+)((\s+\w+(=\w+)?)*)$/

      def initialize(tag_name, markup, tokens)
        super
        if markup.strip =~ SYNTAX
          @lang = $1
          @options = {}
          @isTable = false
          if defined?($2) && $2 != ''
            $2.split.each do |opt|
              key, value = opt.split('=')
              if value.nil?
                if key == 'linenos'
                  value = 'inline'
                else
                  value = true
                end
              end

              # TODO: Remove this custom if conditional for the table line
              # numbers once the devs at pygments.rb fix their code.
              #
              # Do not pass the table or linenos options to Pygments. We're
              # handling it locally.
              if key == 'linenos' && value == 'table'
                @isTable = true
                value = false
              end
              if key == 'linenos' && value == 'true'
                @isTable = true
                value = false
              end
              if key == 'linenos' && value == 'inline'
                @isTable = true
                value = false
              end
              @options[key] = value
            end
          end
        else
          raise SyntaxError.new <<-eos
Syntax Error in tag 'highlight' while parsing the following markup:

  #{markup}

Valid syntax: highlight <lang> [linenos]
eos
        end
      end

      def render(context)
        if context.registers[:site].pygments
          render_pygments(context, super)
        else
          render_codehighlighter(context, super)
        end
      end

      def render_pygments(context, code)
        @options[:encoding] = 'utf-8'

        # TODO: Remove the manual addition of the closing table tag once the
        # dev at pygment.rb fix their code. The custom code is simply the
        # conditional operator. Original just passed the code variable. Also
        # add_code_tags was the original func call.

        if @isTable
          output = Pygments.highlight(code, :lexer => @lang, :options => @options).match(/<pre>(.+)<\/pre>/m)[1].to_s.gsub(/ *$/, '') #strip out divs <div class="highlight">
          tableize_code(output, @lang)
        else
          output = Pygments.highlight(code, :lexer => @lang, :options => @options).sub("highlight", "highlight " + @lang)
          add_code_tags(output, @lang)
        end
      end

      def render_codehighlighter(context, code)
        #The div is required because RDiscount blows ass
        <<-HTML
  <div>
    <pre><code class='#{@lang}'>#{h(code).strip}</code></pre>
  </div>
        HTML
      end

      def add_code_tags(code, lang)
        # Add nested <code> tags to code blocks
        # TODO: sub(newpattern) was custom to fix bad substitution
        code = code.sub(/<pre>/,'<pre><code class="' + lang + '">')
        code = code.sub(/<\/pre>/,"</code></pre>")
      end
      
      # Manually add table and structure it the way we want to. (From Octopress)
      def tableize_code (str, lang = 'text')
        table = '<div class="highlight ' + lang + '"><table><tr><td class="gutter"><pre class="line-numbers">'
        code = ''
        str.lines.each_with_index do |line,index|
          table += "<span class='line-number'>#{index+1}</span>\n"
          code  += "<span class='line'>#{line}</span>"
        end
        table += "</pre></td><td class='code'><pre><code class='#{lang}'>#{code}</code></pre></td></tr></table></div>"
      end

    end
  end
end

Liquid::Template.register_tag('highlight', Jekyll::Tags::HighlightBlock)
