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
#  hubot octo active tasks - Returns active tasks
#  hubot octo last X tasks - Returns last X tasks up to 30
#  hubot octo status <criteria> - Returns project's deployed information and latest
#
# Author:
#  bigbam505
#

OctopusClient = require 'octopus-deploy-client'
HttpHelpers = require('../helpers').httpHelpers
OctoHelpers = require('../helpers').octoHelpers
StatusReport = require '../status-report'
MatchProjects = require '../match-projects'

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

  robot.respond /octo status (.+)/i, (msg) ->
    criteria = msg.match[1]
    msg.send 'Retrieving status for you now...'
    client.resources.dashboard.get()
    .then(HttpHelpers.validateSuccess)
    .then(HttpHelpers.getBody)
    .then (dashboard) ->
      projects = MatchProjects.find dashboard.Projects, criteria
      data =
        dashboard: dashboard,
        projects: projects
      releases = projects.map (project) ->
        client.resources.projects.id(project.Id).releases.get()
          .then(HttpHelpers.validateSuccess)
          .then(HttpHelpers.getBody)
      releases.unshift data
      Promise.all releases
    .then (responses) ->
      data = responses.shift()
      mapToStatusReport = StatusReport.createMapper data.dashboard
      projects = data.projects.map mapToStatusReport
      StatusReport.extendWithLatestRelease projects, responses
    .then (statuses) ->
      displays = (StatusReport.formatStatus status for status in statuses)
      resultMessage = if displays.length is 1 then 'Match found' else 'Top 5 matches'
      msg.reply "#{resultMessage} for #{criteria}\n"
      msg.send "#{displays[...].join("\n\n")}"
    .catch (error) ->
      msg.reply error
