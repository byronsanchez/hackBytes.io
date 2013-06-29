# Standard library
require 'rubygems'
require 'rake'
require 'yaml'
require 'fileutils'
require 'time'

SOURCE = "."
CONFIG = {
  'layouts' => File.join(SOURCE, "_layouts"),
  'posts' => File.join(SOURCE, "_posts/blog"),
  'drafts' => File.join(SOURCE, "_posts/_drafts"),
  'post_ext' => "md",
  'editor' => "vim"
}

# Spawn jekyll and compass processes.
task :default => :watch
desc "compile and run the site"
task :default do
  pids = [
    spawn("jekyll"),
    #spawn("scss --watch assets:stylesheets")
    spawn("compass watch .")
    #spawn("coffee -b -w -o javascripts -c assets/*.coffee")
  ]

  trap "INT" do
    Process.kill "INT", *pids
    exit 1
  end

  loop do
    sleep 1
  end
end

# rake post["Post title"]
desc "Create a post in #{CONFIG['posts']}"
task :post, :title do |t, args|
  abort("rake aborted: '#{CONFIG['posts']}' directory not found.") unless FileTest.directory?(CONFIG['posts'])

  title     = args[:title]
  if title.nil? or title.empty?
    raise "Please add a title to your post."
  end

  date     = Time.now.strftime("%Y-%m-%d")
  filename = "#{date}-#{title.gsub(/(\'|\!|\?|\:|\s\z)/,"").gsub(/\s/,"-").downcase}.#{CONFIG['post_ext']}"

  if File.exists?("#{CONFIG['posts']}/#{filename}")
    raise "The post already exists."
  else
    puts "Creating new post: #{CONFIG['posts']}/#{filename}"
    open("#{CONFIG['posts']}/#{filename}", 'w') do |post|
      post.puts "---"
      post.puts "title: \"#{title.gsub(/-/,' ')}\""
      post.puts 'description: false'
      post.puts "date: " + date + " " + (Time.now).strftime('%H:%M:%S')
      post.puts "category: blog"
      post.puts "comments_enabled: true"
      post.puts "layout: blog-post"
      post.puts "tags: []"
      post.puts "---"
    end
    puts "#{CONFIG['posts']}/#{filename} was created."

    if CONFIG['editor'] && !CONFIG['editor'].nil?
      sleep 2
      system "#{CONFIG['editor']} #{CONFIG['posts']}/#{filename}"
    end
  end
end

# rake draft["Post title"]
desc "Create a post in #{CONFIG['drafts']}"
task :draft, :title do |t, args|
  abort("rake aborted: '#{CONFIG['drafts']}' directory not found.") unless FileTest.directory?(CONFIG['drafts'])
  title     = args[:title]

  if title.nil? or title.empty?
    raise "Please add a title to your draft."
  end

  date     = Time.now.strftime("%Y-%m-%d")
  filename = "#{title.gsub(/(\'|\!|\?|\:|\s\z)/,"").gsub(/\s/,"-").downcase}.#{CONFIG['post_ext']}"

  if File.exists?("#{CONFIG['drafts']}/#{filename}")
    raise "The draft already exists."
  else
    puts "Creating new draft: #{CONFIG['drafts']}/#{filename}"
    open("#{CONFIG['drafts']}/#{filename}", 'w') do |post|
      post.puts "---"
      post.puts "title: \"#{title.gsub(/-/,' ')}\""
      post.puts 'description: false'
      post.puts "date:"
      post.puts "category: blog"
      post.puts "comments_enabled: true"
      post.puts "layout: blog-post"
      post.puts "tags: []"
      post.puts "---"
    end
    puts "#{CONFIG['drafts']}/#{filename} was created."

    if CONFIG['editor'] && !CONFIG['editor'].nil?
      sleep 2
      system "#{CONFIG['editor']} #{CONFIG['drafts']}/#{filename}"
    end
  end
end

# rake publish
# rake publish["post-title"]
desc "Move a post from #{CONFIG['drafts']} to #{CONFIG['posts']}"
task :publish, :post do |t, args|
  post      = args[:post]

  if post.nil? or post.empty?
    Dir["#{CONFIG['drafts']}/*.#{CONFIG['post_ext']}"].each do |filename|
      list = File.basename(filename, ".*")
      puts list
    end
  else
    date     = Time.now.strftime("%Y-%m-%d")
    filename = "#{post}.#{CONFIG['post_ext']}"

    FileUtils.mv("#{CONFIG['drafts']}/#{filename}", "#{CONFIG['posts']}/#{date}-#{filename}")
    content  = File.read("#{CONFIG['posts']}/#{date}-#{filename}")
    parsed_content = "#{content.sub("date:", "date: #{date} " + (Time.now).strftime('%H:%M:%S'))}"
    File.write("#{CONFIG['posts']}/#{date}-#{filename}", parsed_content)
    puts "#{CONFIG['drafts']}/#{filename} was moved to #{CONFIG['posts']}/#{date}-#{filename}."
    
    if CONFIG['editor'] && !CONFIG['editor'].nil?
      sleep 2
      system "#{CONFIG['editor']} #{CONFIG['posts']}/#{date}-#{filename}"
    end
  end
end

# rake page["Page title"]
# rake page["Page title","Path/to/folder"]
# rake page["Page title","Path/to/folder","File extension"]
desc "Create a page (with an optional filepath)"
task :page, :title, :path, :ext do |t, args|
  title     = args[:title]
  filepath  = args[:path]
  extension  = args[:ext]

  if title.nil? or title.empty?
    raise "Please add a title to your page."
  end

  if filepath.nil? or filepath.empty?
    filepath = "./"
  else
    FileUtils.mkdir_p("#{filepath}")
  end
  
  if extension.nil? or extension.empty?
    extension = CONFIG['post_ext']
  end

  filename = "index.#{extension}"

  if File.exists?("#{filepath}/#{filename}")
    raise "The page already exists."
  else
    puts "Creating new page: #{filepath}/#{filename}"
    open("#{filepath}/#{filename}", 'w') do |post|
      post.puts "---"
      post.puts "title: \"#{title.gsub(/-/,' ')}\""
      post.puts 'description: ""'
      post.puts "layout: blog-post"
      post.puts "---"
    end
    puts "#{filepath}/#{filename} was successfully created."

    if CONFIG['editor'] && !CONFIG['editor'].nil?
      sleep 2
      system "#{CONFIG['editor']} #{filepath}/#{filename}"
    end
  end
end

# rake env["0-1"]
# where 0 = development and 1 = production. No defaults. One must be selected.
desc "Switch environments between development and production."
task :env, :env_id do |t, args|
  env_id      = args[:env_id]
  
  if env_id.nil? or env_id.empty?
    abort("rake aborted: please look at your _config.yml file and specify the proper environment to switch to.")
  end

  system("ruby ./assets/scripts/env.rb #{env_id}")
end

# rake compile
desc "Compile every file used for hackBytes."
task :compile do
  system("ruby ./assets/scripts/compile.rb")
end

# rake deploy
desc "Deploy the app to the production server."
task :deploy do
  system("ruby ./assets/scripts/deploy.rb")
end

# rake nuke
# where list = list all available options and all = nuke the project
desc "Removes all copyrighted material under which no reuse license has been provided."
task :nuke, :nuke_op do |t, args|
  nuke_op       = args[:nuke_op]
  
  system("ruby ./assets/scripts/nuke.rb #{nuke_op}")
end
