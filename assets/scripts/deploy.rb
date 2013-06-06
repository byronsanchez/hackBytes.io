#!/usr/bin/env ruby
#
# Deployment script.

#######################
# Script configuration.
#######################

require 'pathname'

# Root project directory
PROJECT_DIR = ENV['HOME'] + "/Developer/web/hackbytes.com"
# For color output when necessary.
require PROJECT_DIR + '/assets/scripts/colorize'


#######################
# Function definitions.
#######################

# Synchronizes the entire _site/ directory with the live server-side directory.
# Only changed files are sent.
def server_push_full()
  # Sync the _site/ directory with hackbytes.com
  puts "---------------------"
  puts "Rsyncing with server."
  puts "---------------------"

  # TODO: RSYNC COMMAND HERE
end

# Renders the deployment result to STDOUT.
def render_exit_status()
  puts "hackBytes has been succesfully deployed.".green
end

# Performs a full deployment of the entire website.
def execute_deploy_full()
  server_push_full()
  render_exit_status()
end


#################################
# Main argument validation phase.
#################################

puts "Deploying application..."
execute_deploy_full()

exit
