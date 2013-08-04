#!/usr/bin/env ruby
#
# Environment switch script.
#
# This script switches between development and production environments.
# Tailored to Byron Sanchez's production environment, but it can be
# used as a template as it shows which components of the project are
# dependent on the environment.
#
# NOTE: If you change the project location, things WILL break. Do a grep
# to find out which files contains paths that will be affected by any
# root directory changes.

require 'pathname'
require ENV['HOME'] + '/Developer/web/hackbytes.com/assets/scripts/colorize' # in same directory as this file.

#######################
# Script configuration.
#######################

# Root project directory
PROJECT_DIR = ENV['HOME'] + "/Developer/web/hackbytes.com"

# Absolute paths for files that need to be updated for production.
FILE_CONFIG           = PROJECT_DIR + "/_config.yml"
FILE_COMPILE          = PROJECT_DIR + "/assets/scripts/compile.rb"

#######################
# Function definitions.
#######################

# Updates project's files to reflect the development environment.
def update_development()
  # Revert all necessary file contents for development.
  puts "Updating files for development."

  #############
  # _config.yml
  #############

  content  = File.read(FILE_CONFIG)
  # domain name
  content = content.sub("http://hackbytes.com", "http://hackbytes-devel.com")
  # future posts
  content = content.sub("future: false", "future: true")
  File.write(FILE_CONFIG, content)
  puts "#{FILE_CONFIG} updated"

  ############
  # compile.rb
  ############

  # We don't want local ruby gem installation in production mode, but we do
  # want it in development mode.
  content = File.read(FILE_COMPILE)
  content = content.sub(/compile_site\(\)[\n\r\s]+?package_resources\(\)/, "compile_site()\ninstall_gems()\npackage_resources()")
  File.write(FILE_COMPILE, content)
  puts "#{FILE_COMPILE} updated"
end

# Updates the project's files to reflect the production environment.
def update_production()
  # Update all necessary file contents for production.
  puts "Updating files for production."

  #############
  # _config.yml
  #############

  content  = File.read(FILE_CONFIG)
  content = content.sub("http://hackbytes-devel.com", "http://hackbytes.com")
  content = content.sub("future: true", "future: false");
  File.write(FILE_CONFIG, content)
  puts "#{FILE_CONFIG} updated"

  ############
  # compile.rb
  ############

  content = File.read(FILE_COMPILE)
  content = content.sub(/compile_site\(\)[\n\r\s]+?install_gems\(\)/, "compile_site()")
  File.write(FILE_COMPILE, content)
  puts "#{FILE_COMPILE} updated"
end

#################################
# Main argument validation phase.
#################################

# Environment Types:
# 0 - The development environment. Use for local devel.
# 1 - The production environment. Use before deployment.
# Default - NONE. One must be selected.
env_type = "-1"

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
    env_type = argument_array[0]
  else
    puts "Please enter a valid environment type. 0 = development, 1 = production".red
    abort
  end
end

# Execute based on deployment type.
case env_type
when "0"
  update_development()
when "1"
  update_production()
else
  puts "Please enter a valid environment type. 0 = development, 1 = production".red
  abort
end

puts "The environment update is complete.".green

exit
