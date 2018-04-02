
module.exports = (env, callback) ->
  options = null
  defaults =
    portfolio: 'portfolio' # directory containing contents to paginate

  updateOptions = () ->
    options = env.config.portfolioHelper or {}
    for key, value of defaults
      options[key] ?= defaults[key]

  if !env.helpers.getPortfolio

    env.helpers.getPortfolio = (contents) ->
      # helper that returns a list of portfolio items found in *contents*
      portfolio = []

      # iterate into the nested directories
      #
      # structure: /project-name/content.html
      for page_key_i, page_value_i of contents["portfolio"]
        for page_key_j, page_value_j of contents["portfolio"][page_key_i]

          if page_value_j["metadata"]
            portfolio.push page_value_j if page_value_j instanceof env.plugins.Page && (page_value_j["metadata"]["published"] == "1" || page_value_j["metadata"]["published"] == 1)

      portfolio.sort (a, b) -> b.date - a.date
      return portfolio

  updateOptions()

  callback()

