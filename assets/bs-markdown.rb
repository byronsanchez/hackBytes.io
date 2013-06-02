#!/usr/bin/env ruby

require 'rubygems'
require 'redcarpet'
require 'pathname'
require 'pygments'

# NOTE: Parallels formatting in _plugins/highlight.rb
class HTMLwithPygments < Redcarpet::Render::XHTML
  # Handles custom signals passed via the language variable.
  # Also handles the language variable normally.
	def block_code(code, lang)
    options = parse_options(lang)

    # Update the language based on our custom options feature.
    lang = options["lang"]

    #lang = lang && lang.split.first || "text"
    
    options[:encoding] = 'utf-8'
    if @isTable
      output = Pygments.highlight(code, :lexer => lang, :options => options).match(/<pre>(.+)<\/pre>/m)[1].to_s.gsub(/ *$/, '') #strip out divs <div class="highlight">
      tableize_code(output, lang)
    else
      output = Pygments.highlight(code, :lexer => lang, :options => options).sub("highlight", "highlight " + lang)
      add_code_tags(output, lang)
    end
	end

  def add_code_tags(code, lang)
    # Add nested <code> tags to code blocks
    # TODO: sub(newpattern) was custom to fix bad substitution
    code = code.sub(/<pre>/,'<pre><code class="' + lang + '">')
    code = code.sub(/<\/pre>/,"</code></pre>")
  end

  def tableize_code (str, lang = '')
    table = '<div class="highlight ' + lang + '"><table><tr><td class="gutter"><pre class="line-numbers">'
    code = ''
    str.lines.each_with_index do |line,index|
      table += "<span class='line-number'>#{index+1}</span>\n"
      code  += "<span class='line'>#{line}</span>"
    end
    table += "</pre></td><td class='code'><pre><code class='#{lang}'>#{code}</code></pre></td></tr></table></div>"
  end

  def parse_options(lang)
    # NOTE: This first portion mirrors highlight.rb's initialize method.

    # Set default options
    options = {"lang" => "text"}
    @isTable = false

    # First split each key-value pair from one another
    unless lang.nil?
      values = lang.split('|')
      # Next split each key value pair and override defaults if necessary.
      values.each_with_index { 
        |val, index| key, value = val.split("=")
        # First key must always be the language
        if index == 0
          if value.nil?
            value = key
            key = "lang"
          end
        else
          # If the value was not defined, handle it
          if value.nil?
            if key == 'linenos'
              value = 'inline'
            else
              value = true
            end
          end
        end
        
        # Hijacking standard Pygments line numbers.
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

        options[key] = value
      }
    end
    
    options
  end

end

def fromMarkdown(text)
	markdown = Redcarpet::Markdown.new(HTMLwithPygments,
		:fenced_code_blocks => true,
		:no_intra_emphasis => true,
		:autolink => true,
		:strikethrough => true,
		:lax_spacing => true,
		:superscript => true,
		:hard_wrap => true,
		:tables => true,
		:xhtml => true,
    :no_styles => true,
    :with_toc_data => true)
	markdown.render(text)
end

