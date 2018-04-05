
module.exports = (env, callback) ->

  if !env.helpers.titleize
    env.helpers.titleize = (content) ->
      return content.toLowerCase().split(' ').map((word) ->
        return (word.charAt(0).toUpperCase() + word.slice(1))
      ).join(' ');

  callback()

