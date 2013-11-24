desc "Create a post in #{@config['drafts']}"
task :draft, :title do |t, args|
  abort("rake aborted: '#{@config['drafts']}' directory not found.") unless FileTest.directory?(@config['drafts'])
  # rake draft["Post title"]
  title     = args[:title]

  if title.nil? or title.empty?
    raise "Please add a title to your draft."
  end

  date     = Time.now.strftime("%Y-%m-%d")
  filename = "#{title.gsub(/(\'|\!|\?|\:|\s\z)/,"").gsub(/\s/,"-").downcase}.#{@config['post_ext']}"

  if File.exists?("#{@config['drafts']}/#{filename}")
    raise "The draft already exists."
  else
    puts "Creating new draft: #{@config['drafts']}/#{filename}"
    open("#{@config['drafts']}/#{filename}", 'w') do |post|
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
    puts "#{@config['drafts']}/#{filename} was created."

    if @config['editor'] && !@config['editor'].nil?
      sleep 2
      system "#{@config['editor']} #{@config['drafts']}/#{filename}"
    end
  end
end

desc "Create a post in #{@config['posts']}"
task :post, :title do |t, args|
  abort("rake aborted: '#{@config['posts']}' directory not found.") unless FileTest.directory?(@config['posts'])

  # rake post["Post title"]
  title     = args[:title]

  if title.nil? or title.empty?
    raise "Please add a title to your post."
  end

  date     = Time.now.strftime("%Y-%m-%d")
  filename = "#{date}-#{title.gsub(/(\'|\!|\?|\:|\s\z)/,"").gsub(/\s/,"-").downcase}.#{@config['post_ext']}"

  if File.exists?("#{@config['posts']}/#{filename}")
    raise "The post already exists."
  else
    puts "Creating new post: #{@config['posts']}/#{filename}"
    open("#{@config['posts']}/#{filename}", 'w') do |post|
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
    puts "#{@config['posts']}/#{filename} was created."

    if @config['editor'] && !@config['editor'].nil?
      sleep 2
      system "#{@config['editor']} #{@config['posts']}/#{filename}"
    end
  end
end

desc "Move a post from #{@config['drafts']} to #{@config['posts']}"
task :publish, :post do |t, args|
  # rake publish
  # rake publish["post-title"]
  post      = args[:post]

  if post.nil? or post.empty?
    Dir["#{@config['drafts']}/*.#{@config['post_ext']}"].each do |filename|
      list = File.basename(filename, ".*")
      puts list
    end
  else
    date     = Time.now.strftime("%Y-%m-%d")
    filename = "#{post}.#{@config['post_ext']}"

    FileUtils.mv("#{@config['drafts']}/#{filename}", "#{@config['posts']}/#{date}-#{filename}")
    content  = File.read("#{@config['posts']}/#{date}-#{filename}")
    parsed_content = "#{content.sub("date:", "date: #{date} " + (Time.now).strftime('%H:%M:%S'))}"
    File.write("#{@config['posts']}/#{date}-#{filename}", parsed_content)
    puts "#{@config['drafts']}/#{filename} was moved to #{@config['posts']}/#{date}-#{filename}."
    
    if @config['editor'] && !@config['editor'].nil?
      sleep 2
      system "#{@config['editor']} #{@config['posts']}/#{date}-#{filename}"
    end
  end
end

desc "Create a page (with an optional filepath)"
task :page, :title, :path, :ext do |t, args|
  # rake page["Page title"]
  # rake page["Page title","Path/to/folder"]
  # rake page["Page title","Path/to/folder","File extension"]
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
    extension = @config['post_ext']
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

    if @config['editor'] && !@config['editor'].nil?
      sleep 2
      system "#{@config['editor']} #{filepath}/#{filename}"
    end
  end
end

