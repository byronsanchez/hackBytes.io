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
  puts "Cleaning #{@config['destination']}..."
  system "rm -rf #{@config['destination']}"
end

desc "Deploy the app to the production server."
task :deploy, :server_env do | t, args |
  # staging
  # production
  server_id   = "-1"
  server_id   = args[:server_env]

  puts "Deploying application..."

  case server_id
  when "staging"
    system "bundle exec cap staging deploy"
  when "production"
    system "bundle exec cap production deploy"
  else
    puts "Please enter a valid server environment: staging | production"
  end
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

