def validate_system
  if RUBY_VERSION != "2.0.0"
    puts "Ruby version 2.0.0 required. Aborting task."
    abort
  end
end

def install_gems
  puts "Installing Gems..."

  if Gem::Specification::find_all_by_name('bundler').nil?
    # Update rdoc first to prevent potential errors in doc conversion if
    # a version less than 4.0.1 is installed.
    system "gem update rdoc"
    system "gem install bundler"
  end

  system "bundle install"
end

desc "Run initial scripts to create a buildable project"
task :init do
  validate_system()
  install_gems()
end

desc "Compiles assets necessary before the website itself can be compiled."
task :precompile do
  build_db()
  precompile_site()
end

desc "Compile every file used for hackBytes."
task :build do
  if @config['environment_id'] == 0
    build_db()
    precompile_site()
  end
  compile_site()
  if @config['environment_id'] == 0
    test_gems_for_site()
  end
  package_resources()
  chmod_site()

  puts "Local compilation complete!".green
end

desc "Perform a clean of the application"
task :clean do
  system "rm -rf #{@config['destination']}"
end

desc "Deploy the app to the production server."
task :deploy do
  puts "Deploying application..."
  execute_deploy_full()
end

# TODO: Abstract the argument checker for env and nuke tasks
desc "Switch environments between development and production."
task :env, :env_id do |t, args|
  # 0 = development
  # 1 = production.
  env_id      = "-1"
  env_id      = args[:env_id]
  
  # Execute based on deployment type.
  case env_id
  when "0"
    update_development()
    puts "The environment update is complete.".green
  when "1"
    update_production()
    puts "The environment update is complete.".green
  else
    getEnvironmentId()
  end
end

desc "Removes all copyrighted material under which no reuse license has been provided."
task :nuke, :nuke_op do |t, args|
  # list = list all available options
  # all = nuke the project
  # Default - help
  nuke_op = "help"
  nuke_op       = args[:nuke_op]
    
  # Execute based on deployment type.
  case nuke_op
  when "all"
    validate_user()
    NUKE.each { |x|
      puts "Nuking... #{x}"
      run_nuke(x)
    }
    puts "Nuke complete!".green
  when "list"
    nuke_list()
  else
    display_help()
    abort
  end
end

