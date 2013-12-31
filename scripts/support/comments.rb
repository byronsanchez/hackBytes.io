#!/usr/bin/env ruby
#
# Takes a YAML structured file and builds a directory for it in the comments
# hierachy.

require 'sqlite3'
require 'securerandom'
require 'digest/md5'

def createCommentsDatabase
  puts "Comments database could not be retrieved from server".red

  # TODO: create database locally (ask yes or no)
end

def createBackupDatabase
  # Do not attempt to extract comments from a file that does not exist.
  if File.exists?("#{@config['database_output']}/#{@config['database_scripts']['comments']}")
    # Make a backup for comparisons in case there are changes to the server
    # database while modifying the local db.
    puts "Creating database backup..."
    system "cp #{@config['database_output']}/#{@config['database_scripts']['comments']} #{@config['database_output']}/#{@config['database_scripts']['comments']}.backup"
  else
    puts "Comments database does not exist.".red
  end
end

def pullCommentsDatabase
  puts "Pulling comments from database..."

  system "rsync -zptlr --progress --delete --rsh='ssh -p#{@config['remote_port']}' #{@config['remote_connection']}:#{@config['remote_database_output']}/#{@config['database_scripts']['comments']} #{@config['database_output']}/#{@config['database_scripts']['comments']}"

  if $?.exitstatus != 0
    #createCommentsDatabase()
    puts "Comments database could not be pulled".red
  else
    createBackupDatabase()
    puts "Comments database pulled successfully".green
  end
end

def pushCommentsDatabase
  # Do not attempt to extract comments from a file that does not exist.
  if File.exists?("#{@config['database_output']}/#{@config['database_scripts']['comments']}")

    local_db = "#{@config['database_output']}/#{@config['database_scripts']['comments']}"
    backup_db = "#{@config['database_output']}/#{@config['database_scripts']['comments']}.backup"
    pre_push_db = "#{@config['database_output']}/#{@config['database_scripts']['comments']}.pre_push_check"
    server_db = "#{@config['remote_connection']}:#{@config['remote_database_output']}/#{@config['database_scripts']['comments']}"

    puts "Checking server database for new comments that may have been submitted during local modifications..."
    system "rsync -zptlr --progress --delete --rsh='ssh -p#{@config['remote_port']}' #{server_db} #{pre_push_db}"

    system "cmp #{backup_db} #{pre_push_db}"

    if $?.exitstatus == 0
      # Clean up the pre_push db
      system "rm #{pre_push_db}"

      puts "No new comments were submitted to the server database."
      puts "Pushing locally modified comments database to server..."

      system "rsync -zptlr --progress --delete --rsh='ssh -p#{@config['remote_port']}' #{local_db} #{server_db}"
      if $?.exitstatus != 0
        #createCommentsDatabase()
        puts "Comments database could not be pushed".red
      else
        # Update the backup since the server has been updated.
        createBackupDatabase()
        puts "Comments database pushed successfully".green
      end
    elsif $?.exitstatus == 1
      puts "New comments were submitted to the server database while the local copy was being modified"
      # mergedb will take care of removing pre_push_db when its done using it
      mergeDatabases(local_db, backup_db, pre_push_db)
    else
      # Clean up the pre_push db
      system "rm #{pre_push_db}"
      puts "Error during comparison!".red
    end
  else
    puts "Comments database does not exist.".red
  end
end

def mergeDatabases(local_db, backup_db, server_db)
  local_sql = "#{@config['assets']}/comments_local_changes.sql"
  backup_sql = "#{@config['assets']}/comments_backup.sql"
  server_sql = "#{@config['assets']}/comments_server_changes.sql"
  merged_sql = "#{@config['assets']}/comments_merged_changes.sql"
  merged_db = "#{@config['assets']}/comments_merged_changes.db"

  puts "Merging server updates with local changes..."
  system "sqlite3 #{local_db} .dump > #{local_sql}"
  system "sqlite3 #{backup_db} .dump > #{backup_sql}"
  system "sqlite3 #{server_db} .dump > #{server_sql}"
  system "merge -p #{local_sql} #{backup_sql} #{server_sql} > #{merged_sql}"

  if $?.exitstatus == 0
    return buildMergedDatabase(local_db, backup_db, server_db)
  elsif $?.exitstatus == 1
    puts "There were merge conflicts. Please do the following:".yellow
    puts "- Resolve the conflicts in #{merged_sql}".yellow
    puts "- Run 'rake comments-merge'".yellow
    abort
  else
    puts "Problems encountered during merge...".red
  end
end

def buildMergedDatabase(local_db, backup_db, server_db)
  local_sql = "#{@config['assets']}/comments_local_changes.sql"
  backup_sql = "#{@config['assets']}/comments_backup.sql"
  server_sql = "#{@config['assets']}/comments_server_changes.sql"
  merged_sql = "#{@config['assets']}/comments_merged_changes.sql"
  merged_db = "#{@config['assets']}/comments_merged_changes.db"

  system "sqlite3 #{merged_db} < #{merged_sql}"
  system "rm #{local_sql} #{backup_sql} #{server_sql} #{merged_sql}"
  system "mv #{merged_db} #{local_db}"
  system "mv #{server_db} #{backup_db}"

  pushCommentsDatabase()
end

def generateCommentsFromDatabase
  # Do not attempt to extract comments from a file that does not exist.
  if File.exists?("#{@config['database_output']}/#{@config['database_scripts']['comments']}")

    # Comments must be cleaned in case previously generated comments were 
    # unpublished.
    clean_generated_comments()

    puts "Generating comments from database..."

    db = SQLite3::Database.new( "#{@config['database_output']}/#{@config['database_scripts']['comments']}" )
    db.execute( "SELECT _id, message FROM comments WHERE isPublished = 1" ) do |row|
      sql_id = row[0]
      message = row[1]
      unless doesCommentExist?(sql_id)
        # Take the input message and build a directory for it.
        build_directory_tree(sql_id, message)
      end
    end
  else
    puts "Failed to generate comments".red
  end
end

def clean_generated_comments()
  if File.exists?(@config['comments'])
    FileUtils.rm_rf(@config['comments'])
  end
end

def doesCommentExist?(sql_id)
  if !Dir.glob("#{@config['comments']}/*/#{sql_id}*.md").empty?
    return true
  else
    return false
  end
end

# Builds the directory for the comment if it does not exist.
def build_folder()
  folder_name = @comment['post_id'].gsub('/', '-')
  # The leading character is expected to be a '/' so strip it.
  folder_name = folder_name[1..-1]

  unless File.directory?("#{@config['comments']}/#{folder_name}")
    FileUtils.mkdir_p("#{@config['comments']}/#{folder_name}")
  end

  folder_name
end

# Creates the file in the specified folder. If the file exists, the file is not
# written and the application is terminated.
def build_file_name(sql_id, comment_id)
  # File Name Strucutre: SQLID_COMMENTUID.EXT
  # SQL ID - The autoinc id which helps keeps comments in order.
  # Comment UID - A unique comment id which allows the comment to be linked to
  # via and html id tag. This cannot change, so it is generated at the time of
  # comment submission and embedded within the comment's YAML data.
  file_name = sql_id.to_s
  # In case there are any spaces, replace it with a dash.
  file_name = file_name.gsub(' ', '_')

  file_name << "_" + comment_id  + "." + @config['comment_ext']
end

# Generates a gravatar hash based on the email address.
def generate_gravatar_hash(email_address)
  if email_address.nil? || email_address.empty?
    @hashed_email_address = Digest::MD5.hexdigest(SecureRandom.hex(8) + "@#{config['base_url']}")
  else
    @hashed_email_address = Digest::MD5.hexdigest(email_address.strip.downcase)
  end
end

# If a name was provided, returns the name. Otherwise, returns a default name
def get_or_set_name(name)
  if name.nil? || name.empty?
    return @config['comments_author']
  else
    return name
  end
end

# The main process for building and creating all components for the comment
# file.
#
# message - a string containing yaml formatted data
def build_directory_tree(sql_id, message)
  @comment = YAML.safe_load(message)

  @folder_name = build_folder()
  @file_name = build_file_name(sql_id, @comment['id'])

  @comment_path = @config['comments'] + "/" + @folder_name + "/" + @file_name

  # Add some data to the YAML hash
  @comment['gravatar_hash'] = generate_gravatar_hash(@comment['email'])
  @comment['name'] = get_or_set_name(@comment['name'])

  # Ruby 1.9.3 quirk. Force UTF-8 encoding.
  # All 1.9 strings have an encoding attached. YAML encodes some
  # non-UTF8 strings as binary, even if they appear to be UTF8.
  # This is because some routines may not return a string with
  # a UTF8 encoding attachment.
  #
  # See: http://stackoverflow.com/questions/9550330/thor-yaml-outputting-as-binary
  utf8_options = {}
  @comment.each_pair { |k,v| utf8_options[k] = ((v.is_a? String) ? v.force_encoding("UTF-8") : v)}

  # To imitate the Jekyll front-matter style, we move the comment
  # content and place it below the actual front-matter.
  comment_content = @comment['comment']
  @comment.delete('comment')

  # Build a string of the complete YAML hash
  # If file exists, don't overwrite it. Terminate the application.
  if File.exists?(@comment_path)
    exit 1
  else
    File.open(@comment_path, 'w') { |f| f.write( @comment.to_yaml + "---\n\n#{comment_content}" ) }
  end
end

def listComments()
  # Do not attempt to extract comments from a file that does not exist.
  if File.exists?("#{@config['database_output']}/#{@config['database_scripts']['comments']}")
    puts "Comments pending approval:"
    puts "\n"

    db = SQLite3::Database.new( "#{@config['database_output']}/#{@config['database_scripts']['comments']}" )
    db.execute( "SELECT _id, message, isPublished FROM comments" ) do |row|
      message = row[1]
      comment = YAML.safe_load(message)
      list_data = {};
      list_data['Post-ID'] = row[0]
      list_data['Post'] = comment['post_id']
      list_data['Author'] = get_or_set_name(comment['name'])
      list_data['Published'] = row[2]

      longest_key = list_data.keys.max { |a, b| a.length <=> b.length }
      list_data.each do |key, value|
        printf "  %-#{longest_key.length}s: %s\n", key, value
      end
      puts "\n"
    end

  else
    puts "Comments database does not exist.".red
  end
end

def viewComment(id)
  # Do not attempt to extract comments from a file that does not exist.
  if File.exists?("#{@config['database_output']}/#{@config['database_scripts']['comments']}")
    puts "Reviewing comment #{id}:"
    puts "\n"

    db = SQLite3::Database.new( "#{@config['database_output']}/#{@config['database_scripts']['comments']}" )
    row = db.get_first_row("SELECT _id, message, isPublished FROM comments WHERE _id = #{id}")
    message = row[1]
    comment = YAML.safe_load(message)

    list_data = {};
    list_data['Post-ID'] = row[0]
    list_data['Post'] = comment['post_id']
    list_data['Author'] = get_or_set_name(comment['name'])
    list_data['Email'] = comment['email']
    list_data['Website'] = comment['link']
    list_data['Published'] = row[2]
    list_data['Message'] = comment['comment']

    longest_key = list_data.keys.max { |a, b| a.length <=> b.length }
    list_data.each do |key, value|
      if key != 'Message'
        printf "  %-#{longest_key.length}s: %s\n", key, value
      else
        printf "  %-#{longest_key.length}s: \n\n", key
        value.each_line do |line|
          printf "    %s", line
        end
        printf "\n\n"
      end
    end

  else
    puts "Comments database does not exist.".red
  end
end

def deleteComment(id)
  # Do not attempt to extract comments from a file that does not exist.
  if File.exists?("#{@config['database_output']}/#{@config['database_scripts']['comments']}")
    puts "Deleting comment #{id}..."

    db = SQLite3::Database.new( "#{@config['database_output']}/#{@config['database_scripts']['comments']}" )
    result = db.execute("DELETE FROM comments WHERE _id = #{id}")
  else
    puts "Comments database does not exist.".red
  end
end

def publishComment(id)
  # Do not attempt to extract comments from a file that does not exist.
  if File.exists?("#{@config['database_output']}/#{@config['database_scripts']['comments']}")
    puts "Publishing comment #{id}..."

    db = SQLite3::Database.new( "#{@config['database_output']}/#{@config['database_scripts']['comments']}" )
    result = db.execute("UPDATE comments SET isPublished = 1 WHERE _id = #{id}")
  else
    puts "Comments database does not exist.".red
  end
end

def unpublishComment(id)
  # Do not attempt to extract comments from a file that does not exist.
  if File.exists?("#{@config['database_output']}/#{@config['database_scripts']['comments']}")
    puts "Unpublishing comment #{id}..."

    db = SQLite3::Database.new( "#{@config['database_output']}/#{@config['database_scripts']['comments']}" )
    result = db.execute("UPDATE comments SET isPublished = 0 WHERE _id = #{id}")
  else
    puts "Comments database does not exist.".red
  end
end

