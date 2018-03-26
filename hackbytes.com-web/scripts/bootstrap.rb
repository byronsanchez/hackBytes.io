require 'rubygems'
require 'rake'
require 'safe_yaml'
require 'fileutils'
require 'time'
require 'jekyll'
require 'pathname'
require 'uglifier'

CONFIG_FILE = File.expand_path('../..', __FILE__) + '/_config.yml'

def load_configuration
  config = YAML.safe_load(File.open(CONFIG_FILE))
  merge_jekyll_configuration(config)
end

def merge_jekyll_configuration(config)
  # Get all of Jekyll's default configs and override them with the manually set
  # config hash. The end result is a hash containing all configs, with default
  # values for any configs that have not been manually set.
  config = Jekyll.configuration(config)
end

@config = load_configuration()

##########################
# Rake Tasks Configuration
##########################

@config['connection_production'] = "#{@config['remote_user']}@#{@config['server_production']}"
@config['connection_staging'] = "#{@config['remote_user']}@#{@config['server_staging']}"

@config['remote_current_path'] = File.join(@config['remote_destination'], "current/_site")
@config['remote_assets'] = File.join(@config['remote_current_path'], "assets")
@config['remote_database_output'] = "/var/lib/nitelite/webserver/hackbytes.com/database"
@config['config_file'] = CONFIG_FILE
@config['editor'] = "vim"
@config['post_ext'] = "md"
@config['comment_ext'] = "md"
@config['comments'] = File.join(@config['source'], "_comments")
@config['layouts'] = File.join(@config['source'], "_layouts")
@config['posts'] = File.join(@config['source'], "_posts/blog")
@config['scripts'] = File.join(@config['source'], "scripts")
@config['tasks'] = File.join(@config['scripts'], "tasks")
@config['support'] = File.join(@config['scripts'], "support")
@config['vendor'] = File.join(@config['source'], "vendor")
@config['assets'] = File.join(@config['source'], "assets")
@config['tests'] = File.join(@config['source'], "_tests")
@config['closure'] = File.join(@config['vendor'], "closure-compiler.jar")
@config['colorize'] = File.join(@config['scripts'], "colorize.rb")
@config['database'] = File.join(@config['assets'], "database")
@config['database_scripts'] = {"comments" => "comments.db", "path" => "path.db"}
@config['database_output'] = File.join(@config['database'], "bin");
@config['comments_author'] = "Anonymous"
# Files to remove from compiled source. These are references to portfolio
# pages.
@config['no_deploy'] = []

###########
# Functions
###########

def load_caps
  Dir["#{@config['caps']}/*.cap"].each {|file|
    # Non .rb files must be imported
    import file
  }
end

def load_tasks
  Dir["#{@config['tasks']}/*.rake"].each {|file|
    # Non .rb files must be imported
    import file
  } 
end

def load_support
  Dir["#{@config['support']}/*.rb"].each {|file|
    # Non .rb files must be imported
    import file
  } 
end

require "#{@config['colorize']}"

