#!/usr/bin/env ruby
#
# Local compilation script.

require 'pathname'

#######################
# Script configuration.
#######################

# Root project directory
PROJECT_DIR = ENV['HOME'] + "/Developer/web/hackbytes.com"
# For color output when necessary.
require PROJECT_DIR + '/assets/scripts/colorize'

# Closure Compiler location
CLOSURE = PROJECT_DIR + "/vendor/closure-compiler.jar"

# Files to remove from compiled source. These are references to portfolio
# pages.
NO_DEPLOY_DIRS = ["coloring-book", "creepypasta-files", "custom-scripts", "hackbytes"]

#######################
# Function definitions.
#######################

# Compiles the entire site. Removes pages from compiled source if they have
# been specified.
def compile_site()
  puts "-------------------"
  puts "Compiling JS files."
  puts "-------------------"
  system "java -jar #{CLOSURE} --compilation_level SIMPLE_OPTIMIZATIONS --js js/_spin.js --js_output_file js/_compiled-spin.js"
  system "java -jar #{CLOSURE} --compilation_level SIMPLE_OPTIMIZATIONS --js js/_jquery.spin.js --js_output_file js/_compiled-jquery.spin.js"
  system "java -jar #{CLOSURE} --compilation_level SIMPLE_OPTIMIZATIONS --js js/_application.js --js js/_bs-comments.js --js_output_file js/_compiled-hackbytes.min.js"
  puts "JS files compiled".green

  puts "-------------------"
  puts "Inserting licenses."
  puts "-------------------"
  # spin.js license
  open("js/hackbytes.min.js", 'w') do |file|
    file.puts "/**"
    file.puts " * spin.js"
    file.puts " * Copyright (c) 2011-2013 Felix Gnass"
    file.puts " * Licensed under the MIT license"
    file.puts " */"
    file.puts "\n"
  end
  system "cat js/_compiled-spin.js >> js/hackbytes.min.js"

  # jquery.spin.js license
  open("js/hackbytes.min.js", 'a') do |file|
    file.puts "\n"
    file.puts "/**"
    file.puts " * jquery.spin.js"
    file.puts " * Copyright (c) 2011-2013 Felix Gnass"
    file.puts " * Licensed under the MIT license"
    file.puts " */"
    file.puts "\n"
  end
  system "cat js/_compiled-jquery.spin.js >> js/hackbytes.min.js"

  # hackBytes license
  open("js/hackbytes.min.js", 'a') do |file|
    file.puts "\n"
    file.puts "/**"
    file.puts " * hackbytes.js"
    file.puts " * Copyright (c) 2013 Byron Sanchez"
    file.puts " * Licensed under the GNU GPL v2.0 license"
    file.puts " * https://www.github.com/byronsanchez/hackbytes.com"
    file.puts " */"
    file.puts "\n"
  end
  system "cat js/_compiled-hackbytes.min.js >> js/hackbytes.min.js"

  # Remove temporary files
  system "rm js/_compiled-*"

  puts "--------------------"
  puts "Compiling CSS files."
  puts "--------------------"
  output = system "bundle exec compass compile #{PROJECT_DIR}"

  if output.nil? || output == 0
    puts "CSS compilation failed. The compass compile command failed to run.".red
  else
    puts "CSS files compiled".green
  end

  puts "-------------------------"
  puts "Compiling entire website."
  puts "-------------------------"
  output = system "bundle exec jekyll --no-auto"

  if output.nil? || output == 0
    puts "Website failed to compile. The jekyll compilation command failed to run.".red
  else
    puts "Website compiled.".green
  end

  # Remove all files listed in the no-deploy array.
  puts "-------------------------------"
  puts "Removing files from deployment."
  puts "-------------------------------"
  NO_DEPLOY_DIRS.each { |dir| system "rm -rf #{PROJECT_DIR}/_site/#{dir}"
                              puts "#{PROJECT_DIR}/_site/#{dir} removed from deployment." }
  puts "Extra files successfully removed".green
end

# Moves the assets gem files to the _site/ directory, as these are needed as
# part of the app.
def package_gems()
  puts "-------------------------"
  puts "Packaging necessary gems."
  puts "-------------------------"
  system "cp #{PROJECT_DIR}/vendor/server/Gemfile #{PROJECT_DIR}/_site/assets/"
  system "cp #{PROJECT_DIR}/vendor/server/Gemfile.lock #{PROJECT_DIR}/_site/assets/"
  system "cp -r #{PROJECT_DIR}/vendor/server/vendor #{PROJECT_DIR}/_site/assets/"
  puts "Packaging gems to directory #{PROJECT_DIR}/_site/assets/"
  
  isDir = false
  # Only run the deployment install if the directory change was successful.
  Dir.chdir("#{PROJECT_DIR}/_site/assets/") do
    isDir = true
    system "bundle install --deployment"
    puts "Required gems packaged successfully".green
  end
  
  if !isDir
    puts "Failed to package gems in #{PROJECT_DIR}/_site/assets/. Check permissions or if the directory exists.".red
    abort
  end
end

# Moves resources files to where they need to be in the _site/ directory. The
# resources directory will not exist in the compiled version of the site.
def package_resources()
  puts "--------------------"
  puts "Packaging resources."
  puts "--------------------"
  system "cp -r #{PROJECT_DIR}/resources/img/ #{PROJECT_DIR}/_site/"
  system "cp -r #{PROJECT_DIR}/resources/favicons/* #{PROJECT_DIR}/_site/"

  puts "Required resources packaged successfully".green
end

# Sets the permissions for the entire site directory which will be preserved
# during the rsync.
def chmod_site()
  puts "-----------------------------------"
  puts "Setting site directory permissions."
  puts "-----------------------------------"

  isDir = false
  # Only run the chmod if the directory change was successful.
  Dir.chdir("#{PROJECT_DIR}/_site/") do
    isDir = true

    puts "Modifying directory permissions..."
    system "find . -type d -exec chmod u=rwx,g=rx,o= '{}' \\;"
    puts "Modifying file permissions..."
    system "find . -type f -exec chmod u=rw,g=r,o= '{}' \\;"

    puts "Required gems packaged successfully".green
  end
  
  if !isDir
    puts "Failed to modify permissions in #{PROJECT_DIR}/_site/. Check your user permissions or if the directory exists.".red
    abort
  end

end


######
# MAIN
######

compile_site()
package_gems()
package_resources()
chmod_site()

puts "Local compilation complete!".green

exit
