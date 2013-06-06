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
FORM_PHP              = PROJECT_DIR + "/assets/bs-forms.php"


#######################
# Function definitions.
#######################

# Updates project's files to reflect the development environment.
def update_development()
  # Revert all necessary file contents for development.
  puts "Updating files for development."

  # FILE_CONFIG
  content  = File.read(FILE_CONFIG)
  parsed_content = content.sub("http://hackbytes.com", "http://hackbytes-devel.com")
  File.write(FILE_CONFIG, parsed_content)
  puts "#{FILE_CONFIG} updated"

  # Ruby PATH configs
  content = File.read(FORM_PHP)
  parsed_content = content.sub("putenv('PATH=' . '/opt/ruby/1.9.3-p374/bin' . getenv('PATH') . PATH_SEPARATOR );", "// putenv('PATH=' . '/opt/ruby/1.9.3-p374/bin' . getenv('PATH') . PATH_SEPARATOR );")
  File.write(FORM_PHP, parsed_content)
  puts "#{FORM_PHP} updated"
end

# Updates the project's files to reflect the production environment.
def update_production()
  # Update all necessary file contents for production.
  puts "Updating files for production."

  # FILE_CONFIG
  content  = File.read(FILE_CONFIG)
  parsed_content = content.sub("http://hackbytes-devel.com", "http://hackbytes.com")
  File.write(FILE_CONFIG, parsed_content)
  puts "#{FILE_CONFIG} updated"

  # Ruby PATH configs
  content = File.read(FORM_PHP)
  parsed_content = content.sub("// putenv('PATH=' . '/opt/ruby/1.9.3-p374/bin' . getenv('PATH') . PATH_SEPARATOR );", "putenv('PATH=' . '/opt/ruby/1.9.3-p374/bin' . getenv('PATH') . PATH_SEPARATOR );")
  File.write(FORM_PHP, parsed_content)
  puts "#{FORM_PHP} updated"
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
