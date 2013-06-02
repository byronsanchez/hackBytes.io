#!/usr/bin/env ruby
#
# The shell interface for bs-markdown.rb

RUBY_FILE_PREVIEW = "./bs-markdown.rb"

require RUBY_FILE_PREVIEW


puts fromMarkdown(ARGF.read)
