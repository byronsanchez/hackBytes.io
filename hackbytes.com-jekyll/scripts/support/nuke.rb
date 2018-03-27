#!/usr/bin/env ruby
#
# Removes all copyrighted material under which no reuse license has
# been granted.

#######################
# Script configuration.
#######################

# Don't modify, unless you are customizing this script for your own
# purposes.
NUKE = [
  "#{@config['source']}/resources/favicons/",
  "#{@config['source']}/resources/img/logo.png",
  "#{@config['source']}/resources/img/launchers/",
  "#{@config['source']}/resources/img/screenshots/",
  "#{@config['source']}/resources/img/current-projects/",
  "#{@config['source']}/resources/img/avatars/avatar-byronsanchez.png",
  "#{@config['source']}/resources/img/screenshots/",
  "#{@config['source']}/_posts/blog/",
  "#{@config['source']}/_posts/portfolio/"
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

