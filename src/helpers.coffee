url = require 'url'

module.exports =
  octoHelpers:
    createLink: (path) ->
      url.resolve(process.env.HUBOT_OCTO_ENDPOINT, path)
    slugIt: (name) ->
      name.toLowerCase().replace(/[\. \s]/g, '-')
  httpHelpers:
    getBody: (response) ->
      new Promise (resolve, reject) ->
        resolve response.body
    validateSuccess: (response) ->
      new Promise (resolve, reject) ->
        if response.status >= 200 || response.status < 300
          resolve response
        else
          reject response
