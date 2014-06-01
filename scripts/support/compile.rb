#!/usr/bin/env ruby
#
# Local compilation script.

# Reads and execute the db schema changescripts in assets/database
def build_db()
  puts "------------------------------"
  puts "Generating the site databases."
  puts "------------------------------"

  Dir.mkdir(@config['database_output']) unless File.exists?(@config['database_output'])

  @config['database_scripts'].each do |path, db|
    puts "Building #{db}..."
    db_dir = "#{@config['database']}/#{path}"
    db_path = "#{@config['database_output']}/#{db}"

    # Only build the database if it does not already exist
    # The path database can always be rebuilt
    system "rm -f #{db_path}" if path == "path"
    if !File.exist?(db_path)
      files = Dir.glob(File.join(db_dir,  '/sc*'))
      files.sort.each { |x|
        system "sqlite3 #{db_path} < #{x}"
      }
      puts "#{db} built successfully!".green
    else
      puts "#{db} already exists".yellow
    end
  end
end

# Precompiles any assets necessary that will not be created on the server.
def precompile_site()
  puts "-------------------"
  puts "Compiling JS files."
  puts "-------------------"
  system "java -jar #{@config['closure']} --compilation_level SIMPLE_OPTIMIZATIONS --js js/_spin.js --js_output_file js/_compiled-spin.js"
  system "java -jar #{@config['closure']} --compilation_level SIMPLE_OPTIMIZATIONS --js js/_jquery.spin.js --js_output_file js/_compiled-jquery.spin.js"
  system "java -jar #{@config['closure']} --compilation_level SIMPLE_OPTIMIZATIONS --js js/_application.js --js js/_bs-comments.js --js_output_file js/_compiled-hackbytes.min.js"
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
end

# Compiles the entire site. Removes pages from compiled source if they have
# been specified.
def compile_site()
  puts "--------------------"
  puts "Compiling CSS files."
  puts "--------------------"
  output = system "bundle exec compass compile #{@config['source']}"

  if output.nil? || output == 0
    puts "CSS compilation failed. The compass compile command failed to run.".red
  else
    puts "CSS files compiled".green
  end

  puts "-------------------------"
  puts "Compiling entire website."
  puts "-------------------------"
  # TODO: If beneficial, use the API to run the build with the environment we 
  # setup so far.
  output = system "bundle exec jekyll build"

  if output.nil? || output == 0
    puts "Website failed to compile. The jekyll compilation command failed to run.".red
  else
    puts "Website compiled.".green
  end

  # Remove all files listed in the no_deploy array.
  puts "-------------------------------"
  puts "Removing files from deployment."
  puts "-------------------------------"
  @config["no_deploy"].each { |dir| system "rm -rf #{@config['destination']}/#{dir}"
                              puts "#{@config['destination']}/#{dir} removed from deployment." }
  puts "Extra files successfully removed".green

  puts "-------------------------"
  puts "Packaging necessary gems."
  puts "-------------------------"
  system "cp #{@config['source']}/vendor/server/Gemfile #{@config['destination']}/assets/"
  system "cp #{@config['source']}/vendor/server/Gemfile.lock #{@config['destination']}/assets/"
end

# Moves the assets gem files to the _site/ directory, as these are needed as
# part of the app.
def test_gems_for_site()
  puts "Installing gems to directory #{@config['destination']}/assets/"
  
  isDir = false
  # Only run the deployment install if the directory change was successful.
  Dir.chdir("#{@config['destination']}/assets/") do
    isDir = true
    Bundler.with_clean_env do
      system "bundle exec gem pristine --all"
    end
    puts "Required gems packaged successfully".green
  end
  
  if !isDir
    puts "Failed to package gems in #{@config['destination']}/assets/. Check permissions or if the directory exists.".red
    abort
  end
end

# Moves resources files to where they need to be in the _site/ directory. The
# resources directory will not exist in the compiled version of the site.
def package_resources()
  puts "--------------------"
  puts "Packaging resources."
  puts "--------------------"
  system "cp -r #{@config['source']}/resources/img/ #{@config['destination']}"
  system "cp -r #{@config['source']}/resources/favicons/* #{@config['destination']}"

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
  Dir.chdir("#{@config['destination']}") do
    isDir = true

    puts "Modifying directory permissions..."
    system "find . -type d -exec chmod u=rwx,g=rx,o= '{}' \\;"
    puts "Modifying file permissions..."
    system "find . -type f -exec chmod u=rw,g=r,o= '{}' \\;"

    puts "Permissions successfully set".green
  end
  
  if !isDir
    puts "Failed to modify permissions in #{@config['destination']}. Check your user permissions or if the directory exists.".red
    abort
  end

end

