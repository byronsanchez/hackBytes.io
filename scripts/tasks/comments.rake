desc "Pull the comments database from the server."
task :"comments-pull" do
  pullCommentsDatabase()
end

desc "Push the comments database from the server."
task :"comments-push" do
  pushCommentsDatabase()
end

desc "Create the comments directory and populate it with comments from the database"
task :"comments-generate" do
  generateCommentsFromDatabase()
end

desc "Lists all unpublished comments"
task :"comments-list" do
  listComments()
end

desc "Displays the specified comment for review"
task :"comments-review", :id do |t, args|
  comment_id = args[:id]
  reviewComment(comment_id)
end


desc "Permanently deletes the specified comment from the database"
task :"comments-delete", :id do |t, args|
  comment_id = args[:id]
  deleteComment(comment_id)
end

desc "Publishes a specified comment"
task :"comments-publish", :id do |t, args|
  comment_id = args[:id]
  publishComment(comment_id)
end

desc "Unpublishes a specified comment"
task :"comments-unpublish", :id do |t, args|
  comment_id = args[:id]
  unpublishComment(comment_id)
end

desc "Resumes the building of a merged database if a conflict has been resolved."
task :"comments-merge" do
  local_db = "#{@config['assets']}/#{@config['comments_database']}"
  backup_db = "#{@config['assets']}/#{@config['comments_database']}.backup"
  server_db = "#{@config['assets']}/#{@config['comments_database']}.pre_push_check"
  buildMergedDatabase(local_db, backup_db, server_db)
end

