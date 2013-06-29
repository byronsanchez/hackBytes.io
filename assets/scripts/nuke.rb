#!/usr/bin/env ruby
#
# Removes all copyrighted material under which no reuse license has
# been granted.

#######################
# Script configuration.
#######################

require 'pathname'
require './assets/scripts/colorize' # in same directory as this file.

PROJECT_DIR = '.'

# Don't modify, unless you are customizing this script for your own
# purposes.
NUKE = [
  "#{PROJECT_DIR}/resources/favicons/",
  "#{PROJECT_DIR}/resources/img/logo.png",
  "#{PROJECT_DIR}/resources/img/launchers/",
  "#{PROJECT_DIR}/resources/img/screenshots/",
  "#{PROJECT_DIR}/resources/img/current-projects/",
  "#{PROJECT_DIR}/resources/img/avatars/avatar-byronsanchez.png",
  "#{PROJECT_DIR}/resources/img/screenshots/",
  "#{PROJECT_DIR}/_posts/blog/",
  "#{PROJECT_DIR}/_posts/portfolio/"
]

#######################
# Function definitions.
#######################

def validate_user
    puts "
    This script is meant to be executed in order to comply with the
    licenses of the project. Information can be found in the COPYRIGHT
    and README files located in the root of the project directory. In
    short, by running the nuke script, you will remove all copyrighted
    materials under which no license of use has been provided. Be careful.
    This may break functionality, so do this when you have replacement
    assets.
    
    To print a list of files to be nuked without actually nuking them,
    run:

      rake nuke['list']\n\n"

  input=""
  print "Are you ready to run the nuke (y/n)? "
  input = $stdin.gets.chomp
  puts "\n"
  if input != "y"
    puts "Nuke aborted!".red
    exit 1
  end
end

def run_nuke(target)
  # Check if the target is directory or file.
  if File.directory?(target)
    # Directory!
    if File.symlink?(target)
      # It is a symlink!
      #system "rm #{target}"
      puts "link"
    else
      # It's a directory!
      #system "rm -rf #{target}"
      puts "folder"
    end
  else
    # It's a file!
    #system "rm #{target}"
    puts "file"
  end
end

def nuke_list
  NUKE.each { |x| puts x }
end

def display_help
  options = [
    "all",
    "list"
  ]
  puts "Usage: " + File.basename(__FILE__) + " [option]"
  puts "Available options:"
  options.each { |option|
    puts " - #{option}"
  }
end

#################################
# Main argument validation phase.
#################################

# Nuke ops:
# all - Removes all copyrighted files for which a license has not been
#       granted.
# list - Lists all files that will be removed during a nuke op, but does
#        not delete or modify anything.
# Default - help
nuke_op = "help"

# Array to hold arguments
argument_array = []

# User can override default.
ARGV.each do|a|
  argument_array << a
end

# Check if arguments were passed (otherwise defaults will be used).
if argument_array.length >= 1
  # Argument validation.
  if argument_array.length == 1
    nuke_op = argument_array[0]
  else
    display_help()
    abort
  end
end

# Execute based on deployment type.
case nuke_op
when "all"
  validate_user()
  NUKE.each { |x|
    puts "Nuking... #{x}"
    run_nuke(x)
  }
  puts "Nuke complete!".green
when "list"
  nuke_list()
else
  display_help()
  abort
end

exit

