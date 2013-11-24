#!/usr/bin/env ruby
#
# Environment switch script.
#
# This script switches between development and production environments.
# Tailored to Byron Sanchez's production environment, but it can be
# used as a template as it shows which components of the project are
# dependent on the environment.

# Updates project's files to reflect the development environment.

def update_development()
  # Revert all necessary file contents for development.
  puts "Updating files for development."

  #############
  # _config.yml
  #############

  content  = File.read(@config['config_file'])
  content = content.sub("http://hackbytes.com", "http://hackbytes-devel.com")
  content = content.sub("future: false", "future: true")
  content = content.sub("environment_id: 1", "environment_id: 0")
  File.write(@config['config_file'], content)
  puts "#{@config['config_file']} updated"
end

# Updates the project's files to reflect the production environment.
def update_production()
  # Update all necessary file contents for production.
  puts "Updating files for production."

  #############
  # _config.yml
  #############

  content  = File.read(@config['config_file'])
  content = content.sub("http://hackbytes-devel.com", "http://hackbytes.com")
  content = content.sub("future: true", "future: false");
  content = content.sub("environment_id: 0", "environment_id: 1")
  File.write(@config['config_file'], content)
  puts "#{@config['config_file']} updated"
end

