desc "Pull the comments database from the server"
task :"comments-pull" do
  pullCommentsDatabase()
end

desc "Push the comments database to the server"
task :"comments-push" do
  pushCommentsDatabase()
end

desc "Create the comments directory and populate it with comments from the database"
task :"comments-generate" do
  generateCommentsFromDatabase()
end

desc "List all comments"
task :"comments-list" do
  listComments()
end

desc "Display the specified comment"
task :"comments-view", :id do |t, args|
  comment_id = args[:id]
  viewComment(comment_id)
end


desc "Permanently delete the specified comment from the database"
task :"comments-delete", :id do |t, args|
  comment_id = args[:id]
  deleteComment(comment_id)
end

desc "Publish a specified comment"
task :"comments-publish", :id do |t, args|
  comment_id = args[:id]
  publishComment(comment_id)
end

desc "Unpublish a specified comment"
task :"comments-unpublish", :id do |t, args|
  comment_id = args[:id]
  unpublishComment(comment_id)
end

desc "Resume the building of a merged database after a conflict has manually been resolved"
task :"comments-merge" do
  db_path = "#{@config['database_output']}/#{@config['database_scripts']['comments']}"
  local_db = "#{db_path}"
  backup_db = "#{db_path}.backup"
  server_db = "#{db_path}.pre_push_check"
  buildMergedDatabase(local_db, backup_db, server_db)
end

