# Description:
#   None
#
# Dependencies:
#   "octopus-deploy-client": "0.1.1"
#
# Configuration:
#   HUBOT_OCTO_ENDPOINT
#   HUBOT_OCTO_APIKEY
#
# Commands:
#   hubot octo active tasks - Returns active tasks
#   hubot octo last X tasks - Returns last X tasks up to 30
#
# Author:
#  bigbam505
#

OctopusClient = require 'octopus-deploy-client'
HttpHelpers = require('../').httpHelpers
OctoHelpers = require('../').octoHelpers

baseUrl = process.env.HUBOT_OCTO_ENDPOINT || ""
apiKey = process.env.HUBOT_OCTO_APIKEY || ""

client = OctopusClient.Create({
  endpoint: baseUrl,
  apiKey: apiKey
})

formatTask = (task) ->
  "> #{task.Description} - #{OctoHelpers.createLink(task.Links.Web)}"

module.exports = (robot) ->
  robot.respond /octo active tasks/i, (msg) ->
    client.resources.tasks.get({active: "true"})
    .then(HttpHelpers.validateSuccess)
    .then(HttpHelpers.getBody)
    .then (body) ->
      tasks = (formatTask task for task in body.Items)
      msg.send "#{body.TotalResults} tasks are running\n#{tasks.join("\n")}"

  robot.respond /octo last (\d+) tasks/i, (msg) ->
    totalTasks = Math.abs(Math.min(30, msg.match[1]))
    client.resources.tasks.get()
    .then(HttpHelpers.validateSuccess)
    .then(HttpHelpers.getBody)
    .then (body) ->
      tasks = (formatTask task for task in body.Items)
      msg.send "Last #{totalTasks} tasks\n#{tasks[0..totalTasks].join("\n")}"
