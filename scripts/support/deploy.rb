#!/usr/bin/env ruby
#
# Deployment script.

# Synchronizes the entire _site/ directory with the live server-side directory.
# Only changed files are sent.
def server_push_full()
  puts "---------------------"
  puts "Rsyncing with server."
  puts "---------------------"
  # Compressing, preserving times, symlinks as symlinks and recursive.
  system "rsync -zptlr --progress --delete --rsh='ssh -p#{@config['remote_port']}' #{@config['destination']}/ #{@config['remote_connection']}:#{@config['remote_destination']}"
  # Install the gems on the server side in case the server's arch is
  # different.
  system "ssh -tp #{@config['remote_port']} #{@config['remote_connection']} \"bash --login -c 'cd #{@config['remote_assets']} && export LANG=en_US.UTF-8 && bundle install --deployment'\""
end

# Renders the deployment result to STDOUT.
def render_exit_status()
  puts "#{@config['title']} has been succesfully deployed.".green
end

# Performs a full deployment of the entire website.
def execute_deploy_full()
  server_push_full()
  render_exit_status()
end

