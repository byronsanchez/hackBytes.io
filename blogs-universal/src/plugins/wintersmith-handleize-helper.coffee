
module.exports = (env, callback) ->

  if !env.helpers.handleize
    env.helpers.handleize = (content, shouldHandleDots) ->
      content = content.toLowerCase().trim().replace(/\s+/g, '-').replace(/[^\w-.]/g, '')

      if shouldHandleDots
        content = content.replace('.', '-')

      return content

  callback()

