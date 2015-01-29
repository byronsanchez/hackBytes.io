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
  puts "-----------------------"
  puts "Compiling Coffee files."
  puts "-----------------------"

  coffeeDir = "coffee/"
  jsDir = "js/"

  Dir.foreach(coffeeDir) do |coffeeFile|
    unless coffeeFile == '.' || coffeeFile == '..'
      js = CoffeeScript.compile File.read("#{coffeeDir}#{coffeeFile}")
      open "#{jsDir}#{coffeeFile.gsub('.coffee', '.js')}", 'w' do |file|
        file.puts js
      end
    end
  end

  puts "Coffee files compiled".green

  puts "-------------------"
  puts "Compiling JS files."
  puts "-------------------"

  File.open("js/hackbytes.min.js", "w") do |file|
    # spin.js
    file.write Uglifier.compile(File.read("vendor/assets/bower_components/spin.js/spin.js"))
    # jquery.spin.js
    file.write Uglifier.compile(File.read("vendor/assets/bower_components/spin.js/jquery.spin.js"))
    # jquery.easing.js
    file.write Uglifier.compile(File.read("vendor/assets/bower_components/jquery-easing-original/jquery.easing.1.3.js"))
    # jquery.mixitup.js
    file.write Uglifier.compile(File.read("vendor/assets/bower_components/mixitup2/src/jquery.mixitup.js"))
    # jquery.jcarousel.js
    file.write Uglifier.compile(File.read("vendor/assets/bower_components/jcarousel/dist/jquery.jcarousel.js"))
    # jquery.pikachoose.js
    file.write Uglifier.compile(File.read("vendor/assets/bower_components/pikachoose-bower/lib/jquery.pikachoose.js"))
    # jquery.fancybox.js
    file.write Uglifier.compile(File.read("vendor/assets/bower_components/fancybox/source/jquery.fancybox.js"))
    # application.js
    file.write Uglifier.compile(File.read("js/application.js"))
    # bs-comments.js
    file.write Uglifier.compile(File.read("js/bs-comments.js"))
  end

  system "cp vendor/assets/bower_components/jquery/dist/jquery.min.js js/jquery.min.js"
  system "cp vendor/assets/bower_components/html5shiv/dist/html5shiv.min.js js/html5shiv.min.js"

  system "cp -r vendor/assets/bower_components/pikachoose-bower/styles css/pikachoose"
  system "cp -r vendor/assets/bower_components/fancybox/source css/fancybox"

  puts "JS files compiled".green

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

