# Locates a global directory and adds it's contents to the content tree

module.exports = (env, callback) ->
  options = null
  defaults =
    globals: '../blogs-universal/src/contents' # directory containing global contents

  updateOptions = () ->
    options = env.config.globalsHelper or {}
    for key, value of defaults
      options[key] ?= defaults[key]

  updateOptions()

  env.registerContentPlugin 'scripts', pattern || '**/main.*(es|es6|jsx|coffee)', WebpackPlugin

  callback()

