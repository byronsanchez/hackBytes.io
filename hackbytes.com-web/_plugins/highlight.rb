# The pygments.rb fix is implemented, but not currently used in favor of the
# tableize function.

module Jekyll
  module Tags
    class HighlightBlock < Liquid::Block
      include Liquid::StandardFilters

      # The regular expression syntax checker. Start with the language specifier.
      # Follow that by zero or more space separated options that take one of three
      # forms: name, name=value, or name="<quoted list>"
      #
      # <quoted list> is a space-separated list of numbers
      SYNTAX = /^([a-zA-Z0-9.+#-]+)((\s+\w+(=(\w+|"([0-9]+\s)*[0-9]+"))?)*)$/

      def initialize(tag_name, markup, tokens)
        super
        if markup.strip =~ SYNTAX
          @lang = $1.downcase || "text"
          @options = {}

          @isTable = false
          if defined?($2) && $2 != ''
            # Split along 3 possible forms -- key="<quoted list>", key=value, or key
            $2.scan(/(?:\w="[^"]*"|\w=\w|\w)+/) do |opt|
              key, value = opt.split('=')

              if value && value.include?("\"")
                  value.gsub!(/"/, "")
                  value = value.split
              end

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

              @options[key.to_sym] = value
            end
          end

          @options[:linenos] = "inline" if @options.key?(:linenos) and @options[:linenos] == true
        else
          raise SyntaxError.new <<-eos
Syntax Error in tag 'highlight' while parsing the following markup:

  #{markup}

Valid syntax: highlight <lang> [linenos]
eos
        end
      end

      def render(context)
        prefix = context["highlighter_prefix"] || ""
        suffix = context["highlighter_suffix"] || ""
        #code = super.to_s.gsub(/^(\n|\r)+|(\n|\r)+$/, '')
        code = super.to_s

        is_safe = !!context.registers[:site].safe

        output =
          case context.registers[:site].highlighter
            when 'pygments'
              render_pygments(code, is_safe)
            when 'rouge'
              render_rouge(code)
            else
              render_codehighlighter(code)
            end

        rendered_output = add_code_tag(output)
        prefix + rendered_output + suffix
      end

      def sanitized_opts(opts, is_safe)
        if is_safe
          Hash[[
            [:startinline, opts.fetch(:startinline, nil)],
            [:hl_linenos,  opts.fetch(:hl_linenos, nil)],
            [:linenos,     opts.fetch(:linenos, nil)],
            [:encoding,    opts.fetch(:encoding, 'utf-8')],
            [:cssclass,    opts.fetch(:cssclass, nil)]
          ].reject {|f| f.last.nil? }]
        else
          opts
        end
      end

      def render_pygments(code, is_safe)
        require 'pygments'

        @options[:encoding] = 'utf-8'

        # TODO: Remove the manual addition of the closing table tag once the
        # dev at pygment.rb fix their code. The custom code is simply the
        # conditional operator. Original just passed the code variable. Also
        # add_code_tags was the original func call.

        if @isTable

          highlighted_code = Pygments.highlight(
            code,
            :lexer   => @lang,
            :options => sanitized_opts(@options, is_safe)
          ).match(/<pre>(.+)<\/pre>/m)[1].to_s.gsub(/ *$/, '') #strip out divs <div class="highlight">

        else

          highlighted_code = Pygments.highlight(
            code,
            :lexer   => @lang,
            :options => sanitized_opts(@options, is_safe)
          ).sub("highlight", "highlight " + @lang)

        end

        if highlighted_code.nil?
          Jekyll.logger.error "There was an error highlighting your code:"
          puts
          Jekyll.logger.error code
          puts
          Jekyll.logger.error "While attempting to convert the above code, Pygments.rb" +
            " returned an unacceptable value."
          Jekyll.logger.error "This is usually a timeout problem solved by running `jekyll build` again."
          raise ArgumentError.new("Pygments.rb returned an unacceptable value when attempting to highlight some code.")
        end

        highlighted_code

      end

      def render_rouge(code)
        require 'rouge'
        formatter = Rouge::Formatters::HTML.new(line_numbers: @options[:linenos], wrap: false)
        lexer = Rouge::Lexer.find_fancy(@lang, code) || Rouge::Lexers::PlainText
        code = formatter.format(lexer.lex(code))
        "<div class=\"highlight\"><pre>#{code}</pre></div>"
      end

      def render_codehighlighter(code)
        "<div class=\"highlight\"><pre>#{h(code).strip}</pre></div>"
      end

      def add_code_tag(code)

        if @isTable
          tableize_code(code)
        else
          # Add nested <code> tags to code blocks
          code = code.sub(/<pre>\n*/,'<pre><code class="' + @lang.to_s.gsub("+", "-") + '" data-lang="' + @lang.to_s + '">')
          code = code.sub(/\n*<\/pre>/,"</code></pre>")
          code.strip
        end
      end

      # Manually add table and structure it the way we want to.
      def tableize_code (str)
        table = '<div class="highlight ' + @lang + '"><table><tr><td class="gutter"><pre class="line-numbers">'
        code = ''

        str.lines.each_with_index do |line,index|
          table += "<span class='line-number'>#{index+1}</span>\n"
          code  += "<span class='line'>#{line}</span>"
        end
        table += "</pre></td><td class='code'><pre><code class='#{@lang}'>#{code}</code></pre></td></tr></table></div>"
      end

    end
  end
end

Liquid::Template.register_tag('highlight', Jekyll::Tags::HighlightBlock)

