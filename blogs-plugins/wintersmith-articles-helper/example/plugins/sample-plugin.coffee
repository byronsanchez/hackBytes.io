module.exports = (env, callback) ->

  console.log "Sample of handleize helper function invoked within a plugin"

  stringToHandleize = "The Wintersmith"
  handleizedString = env.helpers.handleize stringToHandleize

  console.log "String to handleize: " + stringToHandleize
  console.log "Handleized string: " + handleizedString

  callback()

